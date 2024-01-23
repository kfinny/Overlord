# Copyright (c) 2021-present, The osquery authors
#
# This source code is licensed as defined by the LICENSE-Osquery file found in the
# root directory of this source tree.
#
# SPDX-License-Identifier: (Apache-2.0 OR GPL-2.0-only)

function(generateInstallDirectives)
  get_property(augeas_lenses_path
    GLOBAL PROPERTY "AUGEAS_LENSES_FOLDER_PATH"
  )

  if(PLATFORM_LINUX)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      set(CMAKE_INSTALL_PREFIX "/opt/overlord" CACHE PATH "" FORCE)
    endif()

    install(
      FILES "tools/deployment/linux_packaging/deb/conffiles"
      DESTINATION "/control/deb"
    )

    install(
      FILES "tools/deployment/linux_packaging/deb/overlordd.service"
      DESTINATION "/control/deb/lib/systemd/system"
    )

    install(
      FILES "tools/deployment/linux_packaging/deb/copyright"
      DESTINATION "/control/deb"
    )

    install(
      FILES "tools/deployment/linux_packaging/deb/overlord.initd"
      DESTINATION "/control/deb/etc/init.d"
      RENAME "overlordd"

      PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ             GROUP_EXECUTE
        WORLD_READ             WORLD_EXECUTE
    )

    install(
      FILES "tools/deployment/linux_packaging/rpm/overlord.initd"
      DESTINATION "/control/rpm/etc/init.d"
      RENAME "overlordd"

      PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ             GROUP_EXECUTE
        WORLD_READ             WORLD_EXECUTE
    )

    install(
      FILES "tools/deployment/linux_packaging/rpm/overlordd.service"
      DESTINATION "/control/rpm/lib/systemd/system"
    )

    install(
      FILES "tools/deployment/linux_packaging/postinst"
      DESTINATION "/control"
    )

    install(
      TARGETS overlordd
      DESTINATION "bin"
    )

    execute_process(
      COMMAND "${CMAKE_COMMAND}" -E create_symlink overlordd overlordi
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )

    install(
      FILES "${CMAKE_CURRENT_BINARY_DIR}/overlordi"
      DESTINATION "bin"
    )

    install(
      FILES "tools/deployment/overlordctl"
      DESTINATION "bin"

      PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ             GROUP_EXECUTE
        WORLD_READ             WORLD_EXECUTE
    )

    install(
      FILES "tools/deployment/overlord.example.conf"
      DESTINATION "share/overlord"
    )

    install(
      DIRECTORY "${augeas_lenses_path}/"
      DESTINATION "share/overlord/lenses"
      FILES_MATCHING PATTERN "*.aug"
      PATTERN "tests" EXCLUDE
    )

    install(
      FILES "${augeas_lenses_path}/../COPYING"
      DESTINATION "share/overlord/lenses"
    )

    install(
      DIRECTORY "packs"
      DESTINATION "share/overlord"
    )

    install(
      FILES "${CMAKE_SOURCE_DIR}/tools/deployment/certs.pem"
      DESTINATION "share/overlord/certs"
    )

    install(
      FILES "tools/deployment/linux_packaging/overlordd.sysconfig"
      DESTINATION "/control/deb/etc/default"
      RENAME "overlordd"
    )

    install(
      FILES "tools/deployment/linux_packaging/overlordd.sysconfig"
      DESTINATION "/control/rpm/etc/sysconfig"
      RENAME "overlordd"
    )

    install(
      FILES "LICENSE"
      DESTINATION "/control"
      RENAME "LICENSE.txt"
    )

  elseif(PLATFORM_WINDOWS)

    # CMake doesn't prefer 'Program Files' on x64 platforms, more information
    # here: https://gitlab.kitware.com/cmake/cmake/-/issues/18312
    # This is a workaround, to ensure that we leverage 'Program Files' when
    # on a 64 bit system.
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      if(CMAKE_SIZEOF_VOID_P MATCHES "8")
        set(CMAKE_INSTALL_PREFIX "/Program Files/${CMAKE_PROJECT_NAME}" CACHE PATH "" FORCE)
      else()
        set(CMAKE_INSTALL_PREFIX "/Program Files (x86)/${CMAKE_PROJECT_NAME}" CACHE PATH "" FORCE)
      endif()
    endif()

    install(
      TARGETS overlordd
      DESTINATION "overlordd"
    )

    install(
      PROGRAMS "$<TARGET_FILE:overlordd>"
      DESTINATION "."
      RENAME "overlordi.exe"
    )

    install(
      DIRECTORY "tools/deployment/windows_packaging/chocolatey/tools"
      DESTINATION "/control/nupkg"
    )

    install(
      FILES "LICENSE"
      DESTINATION "/control/nupkg/extras"
      RENAME "LICENSE.txt"
    )

    install(
      FILES "LICENSE"
      DESTINATION "/control"
      RENAME "LICENSE.txt"
    )

    # Icon for the MSI package
    install(
      FILES "tools/deployment/windows_packaging/overlord.ico"
      DESTINATION "/control"
    )

    # Icon for the nuget package
    install(
      FILES "tools/deployment/windows_packaging/overlord.png"
      DESTINATION "/control"
    )

    install(
      FILES "tools/deployment/windows_packaging/chocolatey/VERIFICATION.txt"
      DESTINATION "/control/nupkg/extras"
    )

    install(
      FILES "tools/deployment/overlord.example.conf"
      DESTINATION "."
      RENAME "overlord.conf"
    )

    install(
      FILES "tools/wel/overlord.man"
      DESTINATION "."
    )

    install(
      FILES "tools/deployment/windows_packaging/manage-overlordd.ps1"
      DESTINATION "."
    )

    install(
      FILES "tools/deployment/windows_packaging/overlord_utils.ps1"
      DESTINATION "."
    )

    install(
      FILES "tools/deployment/windows_packaging/overlord.flags"
      DESTINATION "."
    )

    install(
      FILES "tools/deployment/windows_packaging/manage-overlordd.ps1"
      DESTINATION "/control/nupkg/extras"
    )

    install(
      FILES "tools/deployment/windows_packaging/overlord_utils.ps1"
      DESTINATION "/control/nupkg/tools"
    )

    install(
      FILES "tools/deployment/windows_packaging/msi/overlord_wix_patch.xml"
      DESTINATION "/control/msi"
    )

    install(
      FILES "tools/deployment/certs.pem"
      DESTINATION "certs"
    )

    install(
      DIRECTORY "packs"
      DESTINATION "."
    )

    install(
      DIRECTORY
      DESTINATION "log"
    )

  elseif(PLATFORM_MACOS)

    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      set(CMAKE_INSTALL_PREFIX "/opt/overlord" CACHE PATH "" FORCE)
    endif()

    install(
      FILES
        "tools/deployment/macos_packaging/overlord.entitlements"
        "tools/deployment/macos_packaging/embedded.provisionprofile"
        "${CMAKE_BINARY_DIR}/tools/deployment/macos_packaging/Info.plist"
        "tools/deployment/macos_packaging/PkgInfo"

      DESTINATION
        "/control"
    )

    install(
      FILES
        "tools/deployment/macos_packaging/pkg/productbuild.sh"

      DESTINATION
        "/control/pkg"

      PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ             GROUP_EXECUTE
        WORLD_READ             WORLD_EXECUTE
    )

    install(
      TARGETS overlordd
      DESTINATION "bin"
    )

    execute_process(
      COMMAND "${CMAKE_COMMAND}" -E create_symlink overlordd overlordi
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    )

    install(
      FILES "${CMAKE_CURRENT_BINARY_DIR}/overlordi"
      DESTINATION "bin"
    )

    install(
      FILES "tools/deployment/overlordctl"
      DESTINATION "bin"
    )

    install(
      DIRECTORY "${augeas_lenses_path}"
      DESTINATION "/private/var/overlord"
      FILES_MATCHING PATTERN "*.aug"
      PATTERN "tests" EXCLUDE
    )

    install(
      DIRECTORY "packs"
      DESTINATION "/private/var/overlord"
    )

    install(
      FILES "tools/deployment/certs.pem"
      DESTINATION "/private/var/overlord/certs"
    )

    install(
      FILES
        "tools/deployment/overlord.example.conf"

      DESTINATION
        "/private/var/overlord"
    )

    install(
      FILES
        "tools/deployment/macos_packaging/pkg/io.overlord.agent.conf"
        "tools/deployment/macos_packaging/pkg/io.overlord.agent.plist"

      DESTINATION
        "/control/pkg"
    )

    install(
      FILES "LICENSE"
      DESTINATION "/control"
      RENAME "LICENSE.txt"
    )

    install(
      TARGETS overlordd
      DESTINATION "overlord.app/Contents/MacOS"
      PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ             GROUP_EXECUTE
        WORLD_READ             WORLD_EXECUTE 
    )

    install(
      FILES
        "tools/deployment/macos_packaging/embedded.provisionprofile"
        "${CMAKE_BINARY_DIR}/tools/deployment/macos_packaging/Info.plist"
        "tools/deployment/macos_packaging/PkgInfo"

      DESTINATION
        "overlord.app/Contents"
    )

    install(
      FILES "tools/deployment/overlordctl"
      DESTINATION "overlord.app/Contents/Resources"
      PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ             GROUP_EXECUTE
        WORLD_READ             WORLD_EXECUTE 
    )

  else()
    message(FATAL_ERROR "Unsupported platform")
  endif()
endfunction()
