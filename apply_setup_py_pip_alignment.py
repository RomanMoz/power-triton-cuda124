#!/usr/bin/env python3
"""
Patch triton/setup.py so `pip install -e .` matches build-triton/buildTriton.sh defaults.

Usage:
  python3 apply_setup_py_pip_alignment.py /path/to/triton
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

MARKER = "BUILDTRITON_SETUP_PY_PIP_ALIGNMENT"


def main() -> int:
    root = os.environ.get("TRITON_ROOT")
    if len(sys.argv) > 1:
        root = sys.argv[1]
    if not root:
        print("Set TRITON_ROOT or pass path to triton checkout", file=sys.stderr)
        return 2
    p = Path(root).resolve() / "setup.py"
    if not p.is_file():
        print(f"Not found: {p}", file=sys.stderr)
        return 2
    text = p.read_text()
    if MARKER in text:
        print(f"Already patched: {p}")
        return 0

    old1 = '''    return check_env_flag("TRITON_OFFLINE_BUILD", "")


# ---- package data ---


def get_triton_cache_path():
    user_home = os.getenv("TRITON_HOME")'''

    new1 = '''    return check_env_flag("TRITON_OFFLINE_BUILD", "")


def get_codegen_backend_names():
    """
    Same meaning as CMake TRITON_CODEGEN_BACKENDS (semicolon-separated in CMake; here env or default).
    Default matches build-triton/buildTriton.sh (nvidia-only). Set TRITON_CODEGEN_BACKENDS=nvidia;amd
    for the historical setuptools default.
    """
    raw = os.environ.get("TRITON_CODEGEN_BACKENDS", "").strip()
    if not raw:
        return ["nvidia"]
    names = [b.strip() for b in re.split(r"[;,]", raw) if b.strip()]
    return list(dict.fromkeys(names))


def apply_offline_default_when_system_llvm():
    """
    If LLVM_SYSPATH is set (typical offline build against /usr/local) but TRITON_OFFLINE_BUILD is
    unset, enable offline so build_helpers does not try to download pinned LLVM (404 on uncommon arch).
    """
    if "TRITON_OFFLINE_BUILD" in os.environ:
        return
    llvm = os.getenv("LLVM_SYSPATH", "").strip()
    if llvm and os.path.isdir(llvm):
        os.environ["TRITON_OFFLINE_BUILD"] = "1"


# ---- package data ---


def get_triton_cache_path():
    explicit = os.getenv("TRITON_CACHE_PATH")
    if explicit:
        return explicit
    user_home = os.getenv("TRITON_HOME")'''

    if old1 not in text:
        print("setup.py: expected block not found (upstream changed?)", file=sys.stderr)
        return 1
    text = text.replace(old1, new1, 1)

    old2 = '''    def build_extension(self, ext):
        lit_dir = shutil.which('lit')'''
    new2 = '''    def build_extension(self, ext):
        apply_offline_default_when_system_llvm()
        lit_dir = shutil.which('lit')'''
    if old2 not in text:
        print("setup.py: build_extension anchor not found", file=sys.stderr)
        return 1
    text = text.replace(old2, new2, 1)

    old3 = '''        # environment variables we will pass through to cmake
        passthrough_args = [
            "TRITON_BUILD_PROTON",
            "TRITON_BUILD_WITH_CCACHE",
            "TRITON_PARALLEL_LINK_JOBS",
            "TRITON_OFFLINE_BUILD",
            "TRITON_LLVM_SYSTEM_SUFFIX",
            "LLVM_SYSPATH",
            "JSON_SYSPATH",
            "TRITON_CUDACRT_PATH",
            "TRITON_CUDART_PATH",
            "TRITON_CUOBJDUMP_PATH",
            "TRITON_CUPTI_INCLUDE_PATH",
            "TRITON_CUPTI_LIB_PATH",
            "TRITON_CUPTI_LIB_BLACKWELL_PATH",
            "TRITON_NVDISASM_PATH",
            "TRITON_PTXAS_PATH",
            "TRITON_PTXAS_BLACKWELL_PATH",
        ]'''
    new3 = '''        # environment variables we will pass through to cmake (align with build-triton/buildTriton.sh)
        passthrough_args = [
            "TRITON_BUILD_PROTON",
            "TRITON_BUILD_WITH_CCACHE",
            "TRITON_PARALLEL_LINK_JOBS",
            "TRITON_OFFLINE_BUILD",
            "TRITON_LLVM_SYSTEM_SUFFIX",
            "LLVM_SYSPATH",
            "LLVM_DIR",
            "MLIR_DIR",
            "LLD_DIR",
            "JSON_SYSPATH",
            "JSON_INCLUDE_DIR",
            "TRITON_CUDACRT_PATH",
            "TRITON_CUDART_PATH",
            "TRITON_CUOBJDUMP_PATH",
            "TRITON_CUPTI_INCLUDE_PATH",
            "TRITON_CUPTI_LIB_PATH",
            "TRITON_CUPTI_LIB_BLACKWELL_PATH",
            "TRITON_NVDISASM_PATH",
            "TRITON_PTXAS_PATH",
            "TRITON_PTXAS_BLACKWELL_PATH",
            "TRITON_CUDA_STDLIB_PATH",
        ]'''
    if old3 not in text:
        print("setup.py: passthrough_args anchor not found", file=sys.stderr)
        return 1
    text = text.replace(old3, new3, 1)

    old4 = 'backends = [*BackendInstaller.copy(["nvidia", "amd"]), *BackendInstaller.copy_externals()]'
    new4 = "backends = [*BackendInstaller.copy(get_codegen_backend_names()), *BackendInstaller.copy_externals()]"
    if old4 not in text:
        print("setup.py: backends line not found", file=sys.stderr)
        return 1
    text = text.replace(old4, new4, 1)

    text = text.rstrip() + f"\n\n# {MARKER}\n"
    p.write_text(text)
    print(f"Patched {p}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
