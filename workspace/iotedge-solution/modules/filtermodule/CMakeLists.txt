cmake_minimum_required(VERSION 3.10)

macro(compileAsC99)
  if (CMAKE_VERSION VERSION_LESS "3.1")
    if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
      set (CMAKE_C_FLAGS "--std=c99 ${CMAKE_C_FLAGS}")
      set (CMAKE_CXX_FLAGS "--std=c++11 ${CMAKE_CXX_FLAGS}")
    endif()
  else()
    set (CMAKE_C_STANDARD 99)
    set (CMAKE_CXX_STANDARD 11)
  endif()
endmacro(compileAsC99)

compileAsC99()

project(main LANGUAGES C)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSE_EDGE_MODULES")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_EDGE_MODULES")

if(CMAKE_CROSSCOMPILING)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDONT_USE_UPLOADTOBLOB")
endif()

# Azure IoT SDK paden via vcpkg
set(VCPKG_INSTALLED_DIR "/opt/vcpkg/installed/arm64-linux")

include_directories(
    ${VCPKG_INSTALLED_DIR}/include
    ${VCPKG_INSTALLED_DIR}/include/azureiot
    ${VCPKG_INSTALLED_DIR}/include/azureiot/inc
)

link_directories(
    ${VCPKG_INSTALLED_DIR}/lib
)

set(main_c_files
    ./main.c
)

add_executable(main ${main_c_files})

target_link_libraries(main
    iothub_client_mqtt_transport
    iothub_client
    parson
    umqtt
    prov_auth_client
    hsm_security_client
    uhttp
    aziotsharedutil
    pthread
    curl
    ssl
    crypto
    m
)

if(CMAKE_CROSSCOMPILING)
    target_link_libraries(main z)
endif()