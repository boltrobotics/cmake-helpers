# Table of Contents

* [Introduction](#introduction)
* [Usage](#usage)
* [Modules](#modules)
* [firmware.cmake](#firmware.cmake)
* [freertos.cmake](#freertos.cmake)
* [gtest.cmake](#gtest.cmake)
* [init.cmake](#init.cmake)
* [project_download.in.cmake](#project_download.in.cmake)
* [project_setup.cmake](#project_setup.cmake)
* [stm32f103c8t6.cmake](#stm32f103c8t6.cmake)
* [unit_testing.cmake](#unit_testing.cmake)

# <a name="introduction"></a>Introduction
The project contains cmake modules which we use when building different projects. Shared modules
save time and help to minimizes mistakes.

# <a name="usage"></a>Usage
Before use, in your CMakeLists.txt set or append the path to the downloaded modules like so:

```
set(CMAKE_MODULE_PATH _DOWNLOADED_PATH_/cmake/Modules)
```
or
```
list(APPEND CMAKE_MODULE_PATH _DOWNLOADED_PATH_/cmake/Modules)
```

# <a name="Modules"></a>Modules

### <a name="firmware.cmake"></a>firmware.cmake
When cross-compiling on a host x86 platform for a target AVR or STM32 platform, the module sets
up a build environment (gcc, libs, etc.) suitable to build binaries for a given target.

```
MyProject/
|-- CMakeLists.txt
|-- src
    |-- common
        |-- ...
    |-- stm32
        |-- CMakeLists.txt
        |-- main.cpp
    |-- avr
        |-- CMakeLists.txt
        |-- main.cpp
    |-- x86
        |-- CMakeLists.txt
        |-- main.cpp
        ....
```      
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
