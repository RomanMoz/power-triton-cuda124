file(REMOVE_RECURSE
  "CMakeFiles/MLIRDialectPluginPassesIncGen"
  "Dialect.cpp.inc"
  "Dialect.h.inc"
  "DialectPluginDialect.md"
  "DialectPluginOps.cpp.inc"
  "DialectPluginOps.h.inc"
  "DialectPluginOps.md"
  "DialectPluginOpsDialect.cpp.inc"
  "DialectPluginOpsDialect.h.inc"
  "DialectPluginOpsTypes.cpp.inc"
  "DialectPluginOpsTypes.h.inc"
  "DialectPluginPasses.h.inc"
  "Ops.cpp.inc"
  "Ops.h.inc"
  "OpsEnums.cpp.inc"
  "OpsEnums.h.inc"
  "Types.cpp.inc"
  "Types.h.inc"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/MLIRDialectPluginPassesIncGen.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
