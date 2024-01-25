
add_overlord_executable(overlord "main.cpp" "main.h")

target_link_libraries(overlord PRIVATE
    overlord_cxx_settings
    overlord_c_settings
    thirdparty_sleuthkit_base
    thirdparty_sleuthkit_base_cpp
    thirdparty_sleuthkit_util
    thirdparty_sleuthkit_util_cpp
    thirdparty_sleuthkit_settings
    thirdparty_openssl
    thirdparty_yara
    thirdparty_zlib
    thirdparty_httplib)
