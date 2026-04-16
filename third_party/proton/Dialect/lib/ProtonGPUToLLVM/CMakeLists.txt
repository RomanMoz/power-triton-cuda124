add_triton_library(ProtonGPUToLLVM
    AllocateProtonSharedMemory.cpp
    PatternProtonGPUOpToLLVM.cpp
    Utility.cpp

    DEPENDS
    ProtonGPUConversionPassIncGen

    LINK_LIBS PUBLIC
    ProtonIR
    ProtonGPUIR
    ProtonAnalysis
)

add_subdirectory(ProtonNvidiaGPUToLLVM)
if("amd" IN_LIST TRITON_CODEGEN_BACKENDS)
  add_subdirectory(ProtonAMDGPUToLLVM)
endif()
# BUILDTRITON_PATCH_NO_AMD_PROTON
