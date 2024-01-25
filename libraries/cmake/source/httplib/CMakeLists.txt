function(httplibMain)
  set(library_root "${CMAKE_CURRENT_SOURCE_DIR}/src")

  add_library(thirdparty_httplib INTERFACE)

  target_include_directories(thirdparty_httplib INTERFACE
    "${library_root}"
  )

  target_include_directories(thirdparty_httplib SYSTEM INTERFACE
    "${library_root}"
  )
endfunction()

httplibMain()
