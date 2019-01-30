# Introduction

The repository contains CMake modules and example files which help to save time when
setting up new C/C++ projects. The main goal is to resuse working solutions to common
problems such as:

* Combining of cross-compilation for AVR / STM32F103 with unit testing on x86 platform
* Downloading and refreshing of dependencies
* Setting up paths to headers, sources and libraries
* Typing boilerplate code around initialization and checks
* Cluttering build files with large, duplicated blocks of instructions
* Recurrent researching of facts about CMake

# Table of Contents

* [Example](#Example)
* [Details](#Details)
  * [make.sh](#make.sh)
  * [init.cmake](#init.cmake)
  * [init.cmake](#init.cmake)
  * [firmware.cmake](#firmware.cmake)
  * [freertos.cmake](#freertos.cmake)
  * [gtest.cmake](#gtest.cmake)
  * [project_setup.cmake](#project_setup.cmake)
  * [project_download.in.cmake](#project_download.in.cmake)
  * [stm32f103c8t6.cmake](#stm32f103c8t6.cmake)
  * [unit_testing.cmake](#unit_testing.cmake)
* [Contribute](#Contribute)

# <a name="Example"></a>Example

Directory ["example"](example/) represents a hypotethical cross-compilation project, structured like so:
```
example/
|-- CMakeLists.txt
|-- make.sh
|-- src
    |-- avr
        |-- CMakeLists.txt
        |-- main.cpp
    |-- common
        |-- example.cpp
        |-- example.hpp
    |-- stm32
        |-- CMakeLists.txt
        |-- FreeRTOSConfig.h
        |-- main.cpp
        |-- opencm3.c
        |-- stm32f103c8t6.ld
    |-- x86
        |-- CMakeLists.txt
        |-- main.cpp
|-- test
    |-- CMakeLists.txt
    |-- main.cpp
    |-- example_test.cpp
```

If my build targets all three platforms, I'd start the build by using
[make.sh](#make.sh):

```
./make.sh -x -s -a -b mega -c atmega2560 -p /dev/ttyACM0 -- -DENABLE_TESTS=ON
```

# <a name="Details"></a>Details

In CMakeLists.txt files, set the path to modules like so:
```
set(CMAKE_MODULE_PATH _INSTALLATION_PATH_/cmake/Modules)
```

### <a name="make.sh"></a>make.sh

### <a name="firmware.cmake"></a>firmware.cmake

When cross-compiling on a host x86 platform for a target AVR or STM32 platform, the module sets
up a build environment (gcc, libs, etc.) suitable to build binaries for a given target.

 portable code.

### <a name="freertos.cmake"></a>freertos.cmake
Sets up FreeRTOS source/header files and directories, heap configuration
### <a name="gtest.cmake"></a>gtest.cmake
Adds gtest project as part of a current build
### <a name="init.cmake"></a>init.cmake
Initializes common variables such as verbosity, build type, c++ standard, unit testing, etc.
### <a name="project_download.in.cmake"></a>project_download.in.cmake
Provides cmake template for importing external projects from a github repository
### <a name="project_setup.cmake"></a>project_setup.cmake
Sets up external projects
### <a name="stm32f103c8t6.cmake"></a>stm32f103c8t6.cmake
Configures variables for building stm32f103 firmware
### <a name="unit_testing.cmake"></a>unit_testing.cmake
Enables unit testing and adds subdirectory containing the tests

# <a name="Contribute"></a>Contribute

Consider supporting this project by contributing to its development.

