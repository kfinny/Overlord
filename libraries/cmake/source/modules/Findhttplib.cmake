include("${CMAKE_CURRENT_LIST_DIR}/utils.cmake")

importSourceSubmodule(
  NAME "httplib"

  SHALLOW_SUBMODULES
    "src"
)
