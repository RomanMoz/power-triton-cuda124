file(REMOVE_RECURSE
  "AttrInterfaces.cpp.inc"
  "AttrInterfaces.h.inc"
  "CMakeFiles/TritonTableGen"
  "Dialect.cpp.inc"
  "Dialect.h.inc"
  "OpInterfaces.cpp.inc"
  "OpInterfaces.h.inc"
  "Ops.cpp.inc"
  "Ops.h.inc"
  "OpsEnums.cpp.inc"
  "OpsEnums.h.inc"
  "TritonDialect.md"
  "TritonOps.md"
  "TypeInterfaces.cpp.inc"
  "TypeInterfaces.h.inc"
  "Types.cpp.inc"
  "Types.h.inc"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/TritonTableGen.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
