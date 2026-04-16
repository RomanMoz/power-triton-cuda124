#!/usr/bin/env bash
# Configure & build Triton (offline, LLVM /usr/local, CUDA 12.4).
#
# Supported layouts (override with TRITON_ROOT / BUILD_DIR):
# - Script inside the triton repo (e.g. triton/buildTriton.sh next to CMakeLists.txt):
#     TRITON_ROOT = directory containing this CMakeLists.txt, BUILD_DIR = <parent>/build-triton
# - Script in an out-of-tree build folder (e.g. build-triton/buildTriton.sh):
#     BUILD_DIR = that folder, TRITON_ROOT = ../triton

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
_search="${SCRIPT_DIR}"
TRITON_ROOT_FOUND=""
while [[ -n "${_search}" && "${_search}" != "/" ]]; do
  if [[ -f "${_search}/CMakeLists.txt" && -d "${_search}/python/triton" ]]; then
    TRITON_ROOT_FOUND="${_search}"
    break
  fi
  _search="$(dirname "${_search}")"
done

if [[ -n "${TRITON_ROOT_FOUND}" ]]; then
  TRITON_ROOT="${TRITON_ROOT:-${TRITON_ROOT_FOUND}}"
  _parent="$(dirname "${TRITON_ROOT}")"
  BUILD_DIR="${BUILD_DIR:-${_parent}/build-triton}"
else
  BUILD_DIR="${BUILD_DIR:-${SCRIPT_DIR}}"
  TRITON_ROOT="${TRITON_ROOT:-$(cd "${SCRIPT_DIR}/../triton" && pwd)}"
fi

LLVM_PREFIX="/usr/local"
CUDA_HOME="${CUDA_HOME:-/usr/local/cuda-12.4}"
export CUDA_HOME
export CUDA_PATH="${CUDA_PATH:-${CUDA_HOME}}"
# Required so third_party/nvidia builds; example plugins depend on TritonNVIDIAGPU* TableGen targets.
TRITON_CODEGEN_BACKENDS="${TRITON_CODEGEN_BACKENDS:-nvidia}"
CACHE_PATH="${TRITON_CACHE_PATH:-${HOME}/.triton}"

echo "buildTriton.sh: TRITON_ROOT=${TRITON_ROOT}" >&2
echo "buildTriton.sh: BUILD_DIR=${BUILD_DIR}" >&2
# Override with e.g. PYTHON=/usr/bin/python3 if that points to the intended version.
PYTHON="${PYTHON:-/usr/bin/python3.11}"

# pybind11 must match the same interpreter (avoid picking site-packages from another Python version).
PYBIND11_DIR="$("${PYTHON}" -c "
import pathlib
import pybind11
try:
    print(pybind11.get_cmake_dir())
except AttributeError:
    print(pathlib.Path(pybind11.__file__).resolve().parent / 'share' / 'cmake' / 'pybind11')
" 2>/dev/null)" || {
  echo "pybind11 missing for ${PYTHON}; run: ${PYTHON} -m pip install pybind11" >&2
  exit 1
}

# JSON_SYSPATH must contain include/nlohmann/json.hpp — cudnn layout is flat; symlink into a prefix.
JSON_PREFIX="${BUILD_DIR}/.nlohmann-prefix"
mkdir -p "${JSON_PREFIX}/include"
ln -sfn "/usr/local/include/cudnn_frontend/thirdparty/nlohmann" "${JSON_PREFIX}/include/nlohmann"

# Upstream sets --cuda-path to third_party/nvidia/backend (headers only). clang needs a full toolkit for GSan.
export TRITON_ROOT
"${PYTHON}" <<'PATCH_GSAN'
import pathlib, re, os, sys
path = pathlib.Path(os.environ["TRITON_ROOT"]) / "third_party/nvidia/CMakeLists.txt"
if not path.is_file():
    sys.exit(0)
text = path.read_text()
if "_gsan_cuda_path" in text:
    sys.exit(0)
pat = re.compile(
    r"set\(GSAN_RUNTIME_PLATFORM_FLAGS\s*\n\s*\"--cuda-path=\$\{CMAKE_CURRENT_SOURCE_DIR\}/backend\"\)"
)
repl = """if(DEFINED ENV{CUDA_HOME} AND NOT "$ENV{CUDA_HOME}" STREQUAL "")
  set(_gsan_cuda_path "$ENV{CUDA_HOME}")
else()
  set(_gsan_cuda_path "${CMAKE_CURRENT_SOURCE_DIR}/backend")
endif()
set(GSAN_RUNTIME_PLATFORM_FLAGS "--cuda-path=${_gsan_cuda_path}")"""
new_text, n = pat.subn(repl, text, count=1)
if n != 1:
    print("buildTriton.sh: GSan cuda-path patch not applied (pattern mismatch); set CUDA_HOME to a full CUDA root", file=sys.stderr)
else:
    path.write_text(new_text)
PATCH_GSAN

# GSan: CUDA atomic_ref<uint16_t> is invalid on some targets (e.g. ppc64le + CUDA 12.4).
"${PYTHON}" <<'PATCH_GSAN_ATOMIC'
import pathlib, re, os, sys
root = pathlib.Path(os.environ["TRITON_ROOT"])
for rel in (
    "python/triton/experimental/gsan/src/GSanLibrary.cu",
    "python/triton/experimental/gsan/src/GSan.h",
):
    p = root / rel
    if not p.is_file():
        continue
    t = p.read_text()
    if (
        "BUILDTRITON_PATCH_GSAN_ATOMIC" in t
        and "sizeof(ShadowCell) == 24" not in t
        and "cuda::atomic_ref<uint16_t" not in t
    ):
        continue
    n = t
    n = re.sub(r"cuda::atomic_ref<uint16_t", "cuda::atomic_ref<uint32_t", n)
    n = re.sub(r"\buint16_t\s+actual\b", "uint32_t actual", n)
    if "GSan.h" in rel:
        n = re.sub(r"\buint16_t\s+numReads\b", "uint32_t numReads", n)
        n = re.sub(r"\buint16_t\s+lock\b", "uint32_t lock", n)
        # uint16_t -> uint32_t bumps ShadowCell size on typical layouts
        n = re.sub(
            r"static_assert\s*\(\s*sizeof\s*\(\s*ShadowCell\s*\)\s*==\s*24\s*\)",
            "static_assert(sizeof(ShadowCell) == 28)",
            n,
        )
    if n != t:
        if "BUILDTRITON_PATCH_GSAN_ATOMIC" not in n:
            n = n.rstrip() + "\n// BUILDTRITON_PATCH_GSAN_ATOMIC\n"
        p.write_text(n)
PATCH_GSAN_ATOMIC

# If amd is not in TRITON_CODEGEN_BACKENDS: third_party/amd is not built (no TableGen .inc).
# - Root CMake: TRITON_HAS_AMD_BACKEND for all TU (RegisterTritonDialects.h, triton_proton.cc).
# - bin/RegisterTritonDialects.h: gate AMD includes / passes / dialect registration.
# - Proton: optional ProtonAMDGPUToLLVM; guard triton_proton.cc AMD pass.
# - proton/hooks/instrumentation.py: optional triton_amd import (proton CLI with nvidia-only libtriton).
export TRITON_CODEGEN_BACKENDS
"${PYTHON}" <<'PATCH_NO_AMD'
import os, pathlib, re, sys

def backends():
    s = os.environ.get("TRITON_CODEGEN_BACKENDS", "")
    return [b.strip() for b in s.replace(";", " ").split() if b.strip()]

if "amd" in backends():
    sys.exit(0)

root = pathlib.Path(os.environ["TRITON_ROOT"])
M = "BUILDTRITON_PATCH_NO_AMD"

# --- Root CMakeLists.txt: global TRITON_HAS_AMD_BACKEND ---
cm = root / "CMakeLists.txt"
if cm.is_file() and M not in cm.read_text():
    t = cm.read_text()
    ins = re.search(
        r'(set\s*\(\s*TRITON_CODEGEN_BACKENDS\s+[^)]*CACHE\s+STRING[^\)]*\)\s*\n)',
        t,
    )
    if ins:
        block = ins.group(1) + f"""
# {M}: used by bin/RegisterTritonDialects.h and proton when amd backend is not built
set(TRITON_HAS_AMD_BACKEND_VALUE 0)
foreach(_codegen_backend ${{TRITON_CODEGEN_BACKENDS}})
  if(_codegen_backend STREQUAL "amd")
    set(TRITON_HAS_AMD_BACKEND_VALUE 1)
  endif()
endforeach()
add_compile_definitions(TRITON_HAS_AMD_BACKEND=${{TRITON_HAS_AMD_BACKEND_VALUE}})
"""
        t = t[: ins.start()] + block + t[ins.end() :]
        cm.write_text(t)
    else:
        print("buildTriton.sh: CMakeLists: TRITON_CODEGEN_BACKENDS line not found; skip define", file=sys.stderr)

# --- bin/RegisterTritonDialects.h ---
# Preprocessor requires #if at line start — never ");#if" / "})#if" on one line. Repair old broken patches.
def repair_register_triton_dialects(text):
    text = re.sub(r"\);#if\b", ");\n#if", text)
    text = re.sub(r"\}\)#if\b", "})\n#if", text)
    text = re.sub(r"\}\)#endif\b", "})\n#endif", text)
    text = re.sub(r"#endif#if\b", "#endif\n#if", text)
    text = re.sub(r"#endif#else\b", "#endif\n#else", text)
    return text

reg = root / "bin" / "RegisterTritonDialects.h"
if reg.is_file():
    t = reg.read_text()
    t = repair_register_triton_dialects(t)
    if M not in t:
        t = re.sub(
            r'(#include "amd/include/Dialect/TritonAMDGPU/IR/Dialect\.h"\s*\n#include "amd/include/TritonAMDGPUTransforms/Passes\.h"\s*\n)',
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = re.sub(
            r'(#include "proton/Dialect/include/Conversion/ProtonGPUToLLVM/ProtonAMDGPUToLLVM/Passes\.h"\s*\n)',
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = re.sub(
            r'(#include "TritonAMDGPUToLLVM/Passes\.h"\s*\n#include "TritonAMDGPUTransforms/Passes\.h"\s*\n#include "TritonAMDGPUTransforms/TritonGPUConversion\.h"\s*\n)',
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = re.sub(
            r"(\s*mlir::test::registerAMDTestAlignmentPass\(\);\s*\n)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = re.sub(
            r"(\s*mlir::test::registerTestAMDGPUMembarPass\(\);\s*\n)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = re.sub(
            r"(\s*mlir::test::registerTestTritonAMDGPURangeAnalysis\(\);\s*\n)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )

        def wrap_between(text, start, end, label):
            i = text.find(start)
            if i < 0:
                print(f"buildTriton.sh: RegisterTritonDialects.h: marker {label!r} start not found", file=sys.stderr)
                return text
            j = text.find(end, i + len(start))
            if j < 0:
                print(f"buildTriton.sh: RegisterTritonDialects.h: marker {label!r} end not found", file=sys.stderr)
                return text
            block = text[i:j]
            if "TRITON_HAS_AMD_BACKEND" in block[:120]:
                return text
            return text[:i] + "#if TRITON_HAS_AMD_BACKEND\n" + block + "#endif\n" + text[j:]

        i0 = t.find("// TritonAMDGPUToLLVM passes")
        if i0 >= 0:
            j_ub = t.find("mlir::ub::registerConvertUBToLLVMInterface", i0)
            if j_ub >= 0:
                block = t[i0:j_ub]
                if "TRITON_HAS_AMD_BACKEND" not in block[:200]:
                    t = t[:i0] + "#if TRITON_HAS_AMD_BACKEND\n" + block + "#endif\n" + t[j_ub:]
            else:
                print("buildTriton.sh: RegisterTritonDialects.h: mlir::ub before amdllvm passes not found", file=sys.stderr)
        t = wrap_between(
            t,
            "// TritonAMDGPUTransforms passes",
            "// NVWS passes",
            "amdtransforms",
        )
        t = re.sub(
            r"(\s*mlir::triton::proton::gpu::registerConvertProtonAMDGPUToLLVM\(\);\s*\n)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        # createAddSchedBarriersPass() is defined only in ProtonAMDGPUToLLVM/AddSchedBarriers.cpp
        t = re.sub(
            r"(\s*mlir::triton::proton::gpu::registerAddSchedBarriersPass\(\);\s*\n)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = re.sub(
            r"(\s*mlir::triton::nvws::NVWSDialect,\s*\n)(\s*mlir::triton::amdgpu::TritonAMDGPUDialect,\s*\n)",
            r"\1#if TRITON_HAS_AMD_BACKEND\n\2#endif\n",
            t,
            count=1,
        )
        t = repair_register_triton_dialects(t)
        t = t.rstrip() + f"\n// {M}\n"
    t = repair_register_triton_dialects(t)
    if "registerAddSchedBarriersPass" in t and not re.search(
        r"#if\s+TRITON_HAS_AMD_BACKEND\s*\n\s*mlir::triton::proton::gpu::registerAddSchedBarriersPass",
        t,
    ):
        t = re.sub(
            r"(\s*mlir::triton::proton::gpu::registerAddSchedBarriersPass\(\);\s*\n)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
        t = repair_register_triton_dialects(t)
    reg.write_text(t)

# --- Proton CMake: conditional ProtonAMDGPUToLLVM subdirs ---
for rel in (
    "third_party/proton/Dialect/include/Conversion/ProtonGPUToLLVM/CMakeLists.txt",
    "third_party/proton/Dialect/lib/ProtonGPUToLLVM/CMakeLists.txt",
):
    p = root / rel
    if not p.is_file():
        continue
    t = p.read_text()
    if M in t:
        continue
    t2, n = re.subn(
        r"add_subdirectory\s*\(\s*ProtonNvidiaGPUToLLVM\s*\)\s*\n\s*add_subdirectory\s*\(\s*ProtonAMDGPUToLLVM\s*\)",
        'add_subdirectory(ProtonNvidiaGPUToLLVM)\nif("amd" IN_LIST TRITON_CODEGEN_BACKENDS)\n  add_subdirectory(ProtonAMDGPUToLLVM)\nendif()',
        t,
        count=1,
    )
    if n == 1:
        p.write_text(t2 + f"\n# {M}\n")

# --- Proton Dialect CMakeLists: add_triton_plugin LINK_LIBS (regex) ---
p = root / "third_party/proton/Dialect/CMakeLists.txt"
if p.is_file() and M not in p.read_text():
    t = p.read_text()
    m = re.search(
        r"if\s*\(\s*TRITON_BUILD_PYTHON_MODULE\s*\)\s*\n\s*add_triton_plugin\s*\(\s*TritonProton\s+\S+\s+LINK_LIBS\s+([^)]+)\)\s*\n\s*target_link_libraries\s*\(\s*TritonProton[\s\S]*?\)\s*\n\s*endif\s*\(\s*\)",
        t,
        re.MULTILINE,
    )
    if m:
        libs = re.split(r"\s+", m.group(1).strip())
        libs = [x for x in libs if x and x != "ProtonAMDGPUToLLVM"]
        libs_s = " ".join(libs)
        repl = f"""if(TRITON_BUILD_PYTHON_MODULE)
 set(_proton_plugin_libs {libs_s})
 if("amd" IN_LIST TRITON_CODEGEN_BACKENDS)
   list(APPEND _proton_plugin_libs ProtonAMDGPUToLLVM)
 endif()
 add_triton_plugin(TritonProton ${{CMAKE_CURRENT_SOURCE_DIR}}/triton_proton.cc LINK_LIBS ${{_proton_plugin_libs}})
 target_link_libraries(TritonProton PRIVATE Python3::Module pybind11::headers)
endif()
# {M}"""
        t = t[: m.start()] + repl + t[m.end() :]
        p.write_text(t)
    else:
        print("buildTriton.sh: proton Dialect CMakeLists: add_triton_plugin(TritonProton...) not matched", file=sys.stderr)

# --- triton_proton.cc ---
p = root / "third_party/proton/Dialect/triton_proton.cc"
if p.is_file():
    t0 = p.read_text()
    t = t0
    if not re.search(
        r'#if\s+TRITON_HAS_AMD_BACKEND\s*\n#include\s+"Conversion/ProtonGPUToLLVM/ProtonAMDGPUToLLVM/Passes\.h"',
        t,
    ):
        t = re.sub(
            r'(#include "Conversion/ProtonGPUToLLVM/ProtonAMDGPUToLLVM/Passes\.h"\s*\n)',
            r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
            t,
            count=1,
        )
    if "add_convert_proton_amd_gpu_to_llvm" in t and not re.search(
        r"#if\s+TRITON_HAS_AMD_BACKEND\s*\n\s*ADD_PASS_WRAPPER_1\s*\(\s*\"add_convert_proton_amd_gpu_to_llvm\"",
        t,
    ):
        t = re.sub(
            r"(ADD_PASS_WRAPPER_1\s*\(\s*\"add_convert_proton_amd_gpu_to_llvm\"[\s\S]*?\)\s*;)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1\n#endif",
            t,
            count=1,
        )
    # createAddSchedBarriersPass lives only in ProtonAMDGPUToLLVM
    if "add_sched_barriers" in t and not re.search(
        r"#if\s+TRITON_HAS_AMD_BACKEND\s*\n\s*ADD_PASS_WRAPPER_0\s*\(\s*\"add_sched_barriers\"",
        t,
    ):
        t = re.sub(
            r"(  ADD_PASS_WRAPPER_0\s*\(\s*\"add_sched_barriers\"[\s\S]*?createAddSchedBarriersPass\);)",
            r"#if TRITON_HAS_AMD_BACKEND\n\1\n#endif",
            t,
            count=1,
        )
    if M not in t:
        t = t.rstrip() + f"\n// {M}\n"
    if t != t0:
        p.write_text(t)

# --- third_party/proton/proton/hooks/instrumentation.py: proton CLI imports amd unconditionally;
#     nvidia-only libtriton has no triton_amd — optional import.
INST = "BUILDTRITON_PATCH_NO_AMD_PROTON_INSTRUMENTATION"
inst_py = root / "third_party/proton/proton/hooks/instrumentation.py"
if inst_py.is_file():
    t0 = inst_py.read_text()
    if INST not in t0 and 'from triton._C.libtriton import amd as triton_amd' in t0:
        t0 = t0.replace(
            "from triton._C.libtriton import amd as triton_amd",
            "try:\n    from triton._C.libtriton import amd as triton_amd\nexcept ImportError:\n"
            f"    triton_amd = None  # {INST}: build without amd backend\n",
            1,
        )
        inst_py.write_text(t0)

# --- Proton Passes.td + Passes.h: AddSchedBarriers is AMD-only; TableGen + manual decl force
#     createAddSchedBarriersPass into libtriton even when RegisterTritonDialects is fixed.
PTD = "BUILDTRITON_PATCH_NO_AMD_PASSES_TD"
ph_td = root / "third_party/proton/Dialect/include/Conversion/ProtonGPUToLLVM/Passes.td"
if ph_td.is_file():
    t0 = ph_td.read_text()
    # TableGen rejects "# ..." as comment; older script versions wrote "# PTD" — fix up.
    if f"\n# {PTD}\n" in t0:
        t0 = t0.replace(f"\n# {PTD}\n", f"\n// {PTD}\n")
        ph_td.write_text(t0)
    if PTD not in t0 and "def AddSchedBarriers" in t0:
        t = re.sub(
            r"\ndef AddSchedBarriers : Pass<\"add-sched-barriers\", \"mlir::ModuleOp\"> \{[\s\S]*?\n\}\n",
            "\n",
            t0,
            count=1,
        )
        if t != t0:
            ph_td.write_text(t.rstrip() + f"\n// {PTD}\n")

PHM = "BUILDTRITON_PATCH_NO_AMD_PASSES_H_MANUAL"
ph_h = root / "third_party/proton/Dialect/include/Conversion/ProtonGPUToLLVM/Passes.h"
if ph_h.is_file():
    t0 = ph_h.read_text()
    if PHM not in t0:
        t = re.sub(
            r"\nstd::unique_ptr<OperationPass<ModuleOp>> createAddSchedBarriersPass\(\);\n",
            "\n",
            t0,
            count=1,
        )
        if t != t0:
            ph_h.write_text(t.rstrip() + f"\n// {PHM}\n")

# --- python/src/gluon_ir.cc: ttag:: ops need TritonAMDGPU headers (third_party/amd) ---
G = "BUILDTRITON_PATCH_GLUON_NO_AMD"

def wrap_gluon_def_block(text, start_name, end_name):
    ms = re.search(rf"(\s*\.def\(\"{re.escape(start_name)}\"\s*,)", text)
    me = re.search(rf"(\s*\.def\(\"{re.escape(end_name)}\"\s*,)", text)
    if not ms or not me or ms.start() >= me.start():
        return text
    i, j = ms.start(), me.start()
    if "TRITON_HAS_AMD_BACKEND" in text[max(0, i - 40) : i + 5]:
        return text
    return (
        text[:i]
        + "#if TRITON_HAS_AMD_BACKEND\n"
        + text[i:j]
        + "#endif\n"
        + text[j:]
    )

p = root / "python" / "src" / "gluon_ir.cc"
if p.is_file():
    t0 = p.read_text()
    t = t0
    if G not in t:
        if not re.search(
            r'#if\s+TRITON_HAS_AMD_BACKEND\s*\n#include "third_party/amd/include/Dialect/TritonAMDGPU',
            t,
        ):
            t = re.sub(
                r'(#include "third_party/amd/include/Dialect/TritonAMDGPU/IR/Dialect\.h"\s*\n)',
                r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
                t,
                count=1,
            )
        if not re.search(
            r"#if\s+TRITON_HAS_AMD_BACKEND\s*\nnamespace ttag",
            t,
        ):
            t = re.sub(
                r"(namespace ttag = mlir::triton::amdgpu;\s*\n)",
                r"#if TRITON_HAS_AMD_BACKEND\n\1#endif\n",
                t,
                count=1,
            )
        # Later region first so earlier byte offsets stay valid.
        t = wrap_gluon_def_block(t, "create_buffer_load", "create_warp_pipeline_border")
        t = wrap_gluon_def_block(t, "create_async_copy_local_to_global", "create_async_copy_mbarrier_arrive")
        t = t.rstrip() + f"\n// {G}\n"
    t = repair_register_triton_dialects(t)
    if t != t0:
        p.write_text(t)

# --- bin/CMakeLists.txt: TritonAMDGPUTestAnalysis is only built with third_party/amd ---
B = "BUILDTRITON_PATCH_BIN_NO_AMD_TEST"
bc = root / "bin" / "CMakeLists.txt"
if bc.is_file() and B not in bc.read_text():
    t = bc.read_text()
    t2, n = re.subn(r"\n\s*TritonAMDGPUTestAnalysis\s*\n", "\n", t)
    if n > 0:
        bc.write_text(t2.rstrip() + f"\n\n# {B}\n")
PATCH_NO_AMD

# --- ppc64le: wrap LLVM/MLIR static archives in --start-group/--end-group (fixes undefined
#     llvm::PassPlugin::Load when ldd shows no libLLVM — all LLVM is inside libtriton.so).
"${PYTHON}" <<'PATCH_PPC64_LLVM_LINK'
import os, pathlib, platform, re, sys

if platform.machine() != "ppc64le":
    sys.exit(0)

root = pathlib.Path(os.environ["TRITON_ROOT"])
cm = root / "CMakeLists.txt"
if not cm.is_file():
    sys.exit(0)

t = cm.read_text()

# llvm::PassPlugin::Load is in libLLVMPlugins.a (not libLLVMPasses.a) in current LLVM.
if not re.search(r"LLVMPasses\s*\n\s*LLVMPlugins\s*\n\s*LLVMNVPTXCodeGen", t):
    t2, n = re.subn(
        r"(LLVMPasses\s*\n)(\s*LLVMNVPTXCodeGen)",
        r"\1    LLVMPlugins\n\2",
        t,
        count=1,
    )
    if n:
        t = t2
        cm.write_text(t)
    else:
        print(
            "buildTriton.sh: CMakeLists: insert LLVMPlugins after LLVMPasses failed",
            file=sys.stderr,
        )

t = cm.read_text()
if "list(REMOVE_ITEM _triton_libs LLVMPasses LLVMPlugins)" in t:
    sys.exit(0)

new = """  # Link triton with its dependencies. On ppc64le, static LLVM/MLIR archives often need
  # --start-group/--end-group. llvm::PassPlugin::Load lives in libLLVMPlugins.a (not
  # libLLVMPasses.a) in current LLVM — LLVMPlugins must be linked; whole-archive helps
  # ppc64le static archive resolution.
  # BUILDTRITON_PATCH_PPC64_LLVM_LINK_GROUP (also applied by buildTriton.sh on ppc64le)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc64le")
    set(_triton_libs ${TRITON_LIBRARIES})
    list(REMOVE_ITEM _triton_libs LLVMPasses LLVMPlugins)
    target_link_libraries(triton PRIVATE
      "-Wl,--start-group"
      ${_triton_libs}
      "-Wl,--whole-archive"
      LLVMPasses
      LLVMPlugins
      "-Wl,--no-whole-archive"
      "-Wl,--end-group")
  else()
    target_link_libraries(triton PRIVATE ${TRITON_LIBRARIES})
  endif()
"""

old_upstream = """  # Link triton with its dependencies
  target_link_libraries(triton PRIVATE ${TRITON_LIBRARIES})
"""

old_group_only = """  # Link triton with its dependencies. On ppc64le, static LLVM/MLIR archives often need
  # --start-group/--end-group or symbols from LLVMPasses (e.g. llvm::PassPlugin::Load)
  # can remain undefined while the link still succeeds.
  # BUILDTRITON_PATCH_PPC64_LLVM_LINK_GROUP (also applied by buildTriton.sh on ppc64le)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc64le")
    target_link_libraries(triton PRIVATE
      "-Wl,--start-group"
      ${TRITON_LIBRARIES}
      "-Wl,--end-group")
  else()
    target_link_libraries(triton PRIVATE ${TRITON_LIBRARIES})
  endif()
"""

old_llvmpasses_only = """  # Link triton with its dependencies. On ppc64le, static LLVM/MLIR archives often need
  # --start-group/--end-group or symbols from LLVMPasses (e.g. llvm::PassPlugin::Load)
  # can remain undefined while the link still succeeds.
  # BUILDTRITON_PATCH_PPC64_LLVM_LINK_GROUP (also applied by buildTriton.sh on ppc64le)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc64le")
    # LLVMPasses alone can still omit PassPlugin.cpp from libLLVMPasses.a; --whole-archive
    # forces every object from that archive (llvm::PassPlugin::Load).
    set(_triton_libs ${TRITON_LIBRARIES})
    list(REMOVE_ITEM _triton_libs LLVMPasses)
    target_link_libraries(triton PRIVATE
      "-Wl,--start-group"
      ${_triton_libs}
      "-Wl,--whole-archive"
      LLVMPasses
      "-Wl,--no-whole-archive"
      "-Wl,--end-group")
  else()
    target_link_libraries(triton PRIVATE ${TRITON_LIBRARIES})
  endif()
"""

if old_llvmpasses_only in t:
    cm.write_text(t.replace(old_llvmpasses_only, new, 1))
elif old_group_only in t:
    cm.write_text(t.replace(old_group_only, new, 1))
elif old_upstream in t:
    cm.write_text(t.replace(old_upstream, new, 1))
else:
    print(
        "buildTriton.sh: CMakeLists: triton link block not recognized; skip ppc64 LLVMPlugins",
        file=sys.stderr,
    )
PATCH_PPC64_LLVM_LINK

cd "${BUILD_DIR}"

cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython3_EXECUTABLE:FILEPATH="${PYTHON}" \
  -Dpybind11_DIR="${PYBIND11_DIR}" \
  -DTRITON_BUILD_PYTHON_MODULE=ON \
  -DTRITON_CODEGEN_BACKENDS="${TRITON_CODEGEN_BACKENDS}" \
  -DTRITON_WHEEL_DIR="${TRITON_ROOT}/python/triton" \
  -DTRITON_CACHE_PATH="${CACHE_PATH}" \
  -DTRITON_OFFLINE_BUILD=ON \
  -DLLVM_SYSPATH="${LLVM_PREFIX}" \
  -DJSON_SYSPATH="${JSON_PREFIX}" \
  -DLLVM_DIR="${LLVM_PREFIX}/lib/cmake/llvm" \
  -DMLIR_DIR="${LLVM_PREFIX}/lib/cmake/mlir" \
  -DTRITON_PTXAS_PATH="${CUDA_HOME}/bin/ptxas" \
  -DTRITON_PTXAS_BLACKWELL_PATH="${CUDA_HOME}/bin/ptxas" \
  -DTRITON_CUOBJDUMP_PATH="${CUDA_HOME}/bin/cuobjdump" \
  -DTRITON_NVDISASM_PATH="${CUDA_HOME}/bin/nvdisasm" \
  -DTRITON_CUDACRT_PATH="${CUDA_HOME}/include" \
  -DTRITON_CUDART_PATH="${CUDA_HOME}/include" \
  -DTRITON_CUPTI_INCLUDE_PATH="${CUDA_HOME}/extras/CUPTI/include" \
  -DTRITON_CUPTI_LIB_PATH="${CUDA_HOME}/extras/CUPTI/lib64" \
  -DTRITON_CUPTI_LIB_BLACKWELL_PATH="${CUDA_HOME}/extras/CUPTI/lib64" \
  -DTRITON_CUDA_STDLIB_PATH="${CUDA_HOME}/include" \
  -DCUPTI_INCLUDE_DIR="${CUDA_HOME}/extras/CUPTI/include" \
  -DROCTRACER_INCLUDE_DIR="${TRITON_ROOT}/third_party/amd/backend/include" \
  -DJSON_INCLUDE_DIR="${JSON_PREFIX}/include" \
  -S "${TRITON_ROOT}" \
  -B "${BUILD_DIR}"

cmake --build "${BUILD_DIR}" -j"$(nproc 2>/dev/null || echo 8)"

cat >&2 <<EOF
--- Next: editable Python install (same CMake dir as this script) ---
  export TRITON_BUILD_DIR="${BUILD_DIR}"
  export LD_LIBRARY_PATH="${LLVM_PREFIX}/lib:\${LD_LIBRARY_PATH}"
  cd "${TRITON_ROOT}" && python3 -m pip install --no-build-isolation -e .
# TRITON_BUILD_DIR is read by python/build_helpers.get_cmake_dir(); without it, pip uses
# TRITON_ROOT/build/cmake.<platform>-... (a second build tree).
# If import still fails on PassPlugin::Load: with static LLVM, ldd shows no libLLVM — use
# BUILDTRITON_PATCH_PPC64_LLVM_LINK_GROUP in CMakeLists (this script adds it on ppc64le), then rebuild.
EOF

# Optional — align setup.py with this script so `pip install -e "${TRITON_ROOT}"` uses nvidia-only
# default, TRITON_CACHE_PATH, LLVM passthrough, offline when LLVM_SYSPATH is set:
#   python3 /path/to/apply_setup_py_pip_alignment.py "${TRITON_ROOT}"
