set(LLVM_TARGET_DEFINITIONS Passes.td)
mlir_tablegen(Passes.h.inc -gen-pass-decls --name ProtonGPUToLLVM)
add_public_tablegen_target(ProtonGPUConversionPassIncGen)

add_subdirectory(ProtonNvidiaGPUToLLVM)
if("amd" IN_LIST TRITON_CODEGEN_BACKENDS)
  add_subdirectory(ProtonAMDGPUToLLVM)
endif()
# BUILDTRITON_PATCH_NO_AMD_PROTON
