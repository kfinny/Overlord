# Copyright (c) 2014-present, The osquery authors
#
# This source code is licensed as defined by the LICENSE-Osquery file found in the
# root directory of this source tree.
#
# SPDX-License-Identifier: (Apache-2.0 OR GPL-2.0-only)

# Detect overlord version
# The OVERLORD_VERSION cache variable will be used if set or not empty
# Otherwise detect version through git and set it in the OVERLORD_VERSION_AUTODETECTED cache variable. If detection fails, 0.0.0 will be used.
# Append OVERLORD_VERSION_SUFFIX cache variable to the final version if specified and the version is detected from git.
# Verify if the final version is composed by three semver components, otherwise fail.
# Returns the final version in OVERLORD_VERSION_INTERNAL and its components in OVERLORD_VERSION_COMPONENTS
function(detectOverlordVersion)
  set(OVERLORD_VERSION "" CACHE STRING "Overrides overlord version with this value")
  set(OVERLORD_VERSION_SUFFIX "" CACHE STRING "String to append when the version is automatically detected")
  set(OVERLORD_VERSION_AUTODETECTED "" CACHE STRING "overlord version autodetected through git. Do not manually set." FORCE)
  set(overlord_version 0.0.0)

  if(NOT OVERLORD_VERSION)
    find_package(Git REQUIRED)

    execute_process(
      COMMAND "${GIT_EXECUTABLE}" describe --tags --always --dirty
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      OUTPUT_VARIABLE branch_version
      RESULT_VARIABLE exit_code
    )

    if(NOT ${exit_code} EQUAL 0)
      message(WARNING "Failed to detect overlord version. Set it manually through OVERLORD_VERSION or 0.0.0 will be used")
    else()
      string(REGEX REPLACE "\n$" "" branch_version "${branch_version}")
      set(overlord_version ${branch_version})
      overwrite_cache_variable("OVERLORD_VERSION_AUTODETECTED" "STRING" ${overlord_version})

      if(OVERLORD_VERSION_SUFFIX)
        string(APPEND overlord_version "${OVERLORD_VERSION_SUFFIX}")
      endif()
    endif()
  else()
    set(overlord_version "${OVERLORD_VERSION}")
  endif()

  string(REPLACE "." ";" overlord_version_components "${overlord_version}")

  list(LENGTH overlord_version_components overlord_version_components_len)

  if(NOT overlord_version_components_len GREATER_EQUAL 3)
    message(FATAL_ERROR "Version should have at least 3 components (semver).")
  endif()

  set(OVERLORD_VERSION_INTERNAL "${overlord_version}" PARENT_SCOPE)
  set(OVERLORD_VERSION_COMPONENTS "${overlord_version_components}" PARENT_SCOPE)
endfunction()

# Always generate the compile_commands.json file
set(CMAKE_EXPORT_COMPILE_COMMANDS true)

# Show verbose compilation messages when building Debug binaries
if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  set(CMAKE_VERBOSE_MAKEFILE true)
endif()

# This may be useful to speed up development builds
option(BUILD_SHARED_LIBS "Whether to build shared libraries (like *.dll or *.so) or static ones (like *.a)" ${BUILD_SHARED_LIBS_DEFAULT_VALUE})

option(ADD_HEADERS_AS_SOURCES "Whether to add headers as sources of a target or not. This is needed for some IDEs which wouldn't detect headers properly otherwise")

option(OVERLORD_NO_DEBUG_SYMBOLS "Whether to build without debug symbols or not, even if a build type that normally have them has been selected")

option(OVERLORD_BUILD_TESTS "Whether to enable and build tests or not")
option(OVERLORD_BUILD_ROOT_TESTS "Whether to enable and build tests that require root access")

# Sanitizers
option(OVERLORD_ENABLE_ADDRESS_SANITIZER "Whether to enable Address Sanitizer")

if(DEFINED PLATFORM_POSIX)
  option(OVERLORD_ENABLE_THREAD_SANITIZER "Whether to enable Thread Sanitizer")
endif()

if(DEFINED PLATFORM_LINUX OR DEFINED PLATFORM_WINDOWS)
  option(OVERLORD_BUILD_FUZZERS "Whether to build fuzzing harnesses")

  if(DEFINED PLATFORM_WINDOWS AND OVERLORD_BUILD_FUZZERS)
    if(OVERLORD_MSVC_TOOLSET_VERSION LESS 143)
      message(FATAL_ERROR "Fuzzers are not supported on MSVC toolset version less than 143")
    endif()
  endif()

  if(DEFINED PLATFORM_LINUX)
    option(OVERLORD_ENABLE_LEAK_SANITIZER "Whether to enable Leak Sanitizer")

    # This is required for Boost coroutines/context to be built in a way that are compatible to Valgrind
    option(OVERLORD_ENABLE_VALGRIND_SUPPORT "Whether to enable support for overlord to be run under Valgrind")

    if(OVERLORD_ENABLE_VALGRIND_SUPPORT AND OVERLORD_ENABLE_ADDRESS_SANITIZER)
      message(FATAL_ERROR "Cannot mix Vagrind and ASAN sanitizers, please choose only one.")
    endif()
  endif()
endif()

if(DEFINED PLATFORM_WINDOWS)
  option(OVERLORD_ENABLE_INCREMENTAL_LINKING "Whether to enable or disable incremental linking (/INCREMENTAL or /INCREMENTAL:NO). Enabling it greatly increases disk usage")
  option(OVERLORD_BUILD_ETW "Whether to enable and build ETW support" ON)
endif()

option(OVERLORD_ENABLE_CLANG_TIDY "Enables clang-tidy support")
set(OVERLORD_CLANG_TIDY_CHECKS "-checks=cert-*,cppcoreguidelines-*,performance-*,portability-*,readability-*,modernize-*,bugprone-*" CACHE STRING "List of checks performed by clang-tidy")

option(OVERLORD_BUILD_BPF "Whether to enable and build BPF support" ON)

set(DEFAULT_BUILD_AWS OFF)
if(DEFINED PLATFORM_WINDOWS AND "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "ARM64")
    message(WARNING "AWS dependency is disabled on windows-arm64 because of missing atomics support")
    set(DEFAULT_BUILD_AWS OFF)
endif()
option(OVERLORD_BUILD_AWS "Whether to build the aws tables and library, to decrease memory usage and increase speed during build." ${DEFAULT_BUILD_AWS})

option(OVERLORD_BUILD_DPKG "Whether to build the dpkg tables" ON)
option(OVERLORD_BUILD_EXPERIMENTS "Whether to build experiments" ON)

option(OVERLORD_ENABLE_FORMAT_ONLY "Configure CMake to format only, not build")

# Unfortunately, due glog always enabling BUILD_TESTING, we have to force it off, so that tests won't be built
overwrite_cache_variable("BUILD_TESTING" "BOOL" "OFF")

if(DEFINED PLATFORM_POSIX)
  option(OVERLORD_ENABLE_CCACHE "Whether to search ccache in the system and use it in the build" ON)
endif()

set(third_party_source_list "source;formula")

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules" CACHE STRING "A list of paths containing CMake module files")
set(OVERLORD_THIRD_PARTY_SOURCE "${third_party_source_list}" CACHE STRING "Sources used to acquire third-party dependencies")

set(OVERLORD_INSTALL_DIRECTIVES "${CMAKE_SOURCE_DIR}/cmake/install_directives.cmake" CACHE FILEPATH "Install directives")

# This is the default S3 storage used by Facebook to store 3rd party dependencies; it
# is provided here as a configuration option
if("${THIRD_PARTY_REPOSITORY_URL}" STREQUAL "")
  set(THIRD_PARTY_REPOSITORY_URL "https://s3.amazonaws.com/osquery-packages")
endif()

# When building on macOS, make sure we are only building one architecture at a time
if(PLATFORM_MACOS)
  list(LENGTH CMAKE_OSX_ARCHITECTURES osx_arch_count)

  if(osx_arch_count GREATER 1)
    message(FATAL_ERROR "The CMAKE_OSX_ARCHITECTURES setting can only contain one architecture at a time")
  endif()
endif()

detectOverlordVersion()

message(STATUS "overlord version: ${OVERLORD_VERSION_INTERNAL}")
