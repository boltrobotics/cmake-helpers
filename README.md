# Introduction

The repository contains CMake modules and example files which help to save time when
setting up new C/C++ projects. The main goal is to resuse working solutions to common
problems such as:

* Combining of cross-compilation for AVR / STM32F103 with unit testing on x86 platform
* Downloading and refreshing of dependencies
* Setting up paths to headers, sources and libraries
* Re-typing boilerplate code around initialization and checks
* Cluttering build files with large, duplicated blocks of instructions
* Recurrent research and refresh of information about CMake

#### Platforms and requirements

An example project was tested on MacOS and Linux. Depending on host and target platforms, not all
the dependencies given below may apply.

Most of the packages can be installed using system package manager or supplimental tools like
brew on MacOS. When a package manager doesn't support a package, the packge is downloaded from
github (for example, gtest, stm32-cmake) or directly from developer's website (for example,
arm gnu embedded toolchain, FreeRTOS).

* x86 software/host platform
  * <a href="https://en.wikipedia.org/wiki/Xcode" target="_blank">Xcode (MacOS)</a>
  * build-essential (Linux)
  * <a href="https://cmake.org/" target="_blank">CMake</a>
  * <a href="https://www.boost.org/" target="_blank">Boost</a>
  * <a href="https://github.com/google/googletest.git" target="_blank">googletest</a>
* To build AVR firmware
  * <a href="https://github.com/queezythegreat/arduino-cmake.git" target="_blank">arduino-cmake</a>
  * <a href="https://www.arduino.cc/en/Main/Software" target="_blank">arduino-sdk</a>
  * avr-gcc
  * <a href="https://www.nongnu.org/avrdude/" target="_blank">avrdude</a>
* To build STM32F103 firmware
  * <a href="https://developer.arm.com/open-source" target="_blank">Arm GNU Embedded Toolchain</a>
  * <a href="https://github.com/boltrobotics/stm32-cmake.git" target="_blank">stm32-cmake</a>
  * <a href="https://github.com/libopencm3/libopencm3.git" target="_blank">libopencm3</a>
  * <a href="https://www.freertos.org/" target="_blank">FreeRTOS</a>
  * st-link tool

# Table of Contents

* [Example](#Example)
* [Details](#Details)
  * [example/make.sh](#make.sh)
  * [example/CMakeLists.txt](#CMakeLists.txt)
  * [example/src/avr/CMakeLists.txt](#avr_CMakeLists.txt)
  * [example/src/stm32/CMakeLists.txt](#stm32_CMakeLists.txt)
  * [example/src/x86/CMakeLists.txt](#x86_CMakeLists.txt)
  * [init.cmake](#init.cmake)
  * [firmware.cmake](#firmware.cmake)
  * [freertos.cmake](#freertos.cmake)
  * [gtest.cmake](#gtest.cmake)
  * [project_setup.cmake](#project_setup.cmake)
  * [project_download.cmake.in](#project_download.cmake.in)
  * [stm32f103c8t6.cmake](#stm32f103c8t6.cmake)
  * [unit_testing.cmake](#unit_testing.cmake)
* [Contribute](#Contribute)

# <a name="Example"></a>Example

Directory ["example"](example/) represents a hypotethical cross-compilation project. Within it:

* src/avr/main.cpp <br>
  Uses Arduino library to blink a built-in LED and call a function Example::hello() while running
  on AVR-based microcontroller such as ATmega2560 
* src/stm32/main.cpp <br>
  Uses libopencm3 and starts FreeRTOS task to blink a built-in LED and call Example::hello() while
  running on STM32F103C8T6 (aka Blue Pill)
* src/x86/main.cpp <br>
  Just calls Example::hello() while running on MacOS or Linux

Project structure:
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

Once the environment is set up (see [Details](#Details)), start the build with [make.sh](#make.sh)
for all three platforms:
```
./make.sh -x -s -a -b mega -c atmega2560 -p /dev/ttyACM0 -- -DENABLE_TESTS=ON
```

The script creates three directories where it builds the artifacts using proper toolchain:
```
example/
|-- ...
|-- build-avr
|-- build-stm32
|-- build-x86
|-- ...
```

To upload just-built firmware to a connected board, change into build-avr or build-stm32 and
execute:
```
make flash
```

To run unit test which is defined in example_test.cpp, change into build-x86 and execute:
```
make test
```

# <a name="Details"></a>Details

#### <a href=example/make.sh name="make.sh">example/make.sh</a>

The script makes it convenient to set up the environment and pass required parameters to cmake.

Example project and cmake modules use specific variables from the environment. One such set
includes the locations of dependent libraries. The locations should be changed to reflect
personal preference:
```bash
if [ -z ${XTRA_HOME} ]; then
  XTRA_HOME=${PWD}/../xtra
fi

export GTEST_HOME=${XTRA_HOME}/gtest
export ARDUINOCMAKE_HOME=${XTRA_HOME}/arduino-cmake
export STM32CMAKE_HOME=${XTRA_HOME}/stm32-cmake
export LIBOPENCM3_HOME=${XTRA_HOME}/libopencm3
export FREERTOS_HOME=${XTRA_HOME}/FreeRTOSv10.1.1
```

Command line options:
```bash
Usage: make.sh [-x] [-s] [-a] [-b _board_] [-c _board_cpu_] [-p _serial_port_] [-u] [-h]
        -x - build x86
        -s - build stm32 (board stm32f103c8t6)
        -a - build avr (must specify board)
        -b - board (uno, mega, etc.)
        -c - board CPU (atmega328, atmega2560, etc.)
        -p - board serial port (e.g. /dev/ttyACM0)
        -u - clone/pull dependencies from github
        -h - this help
```

* -x, -s, -a<br>
Specify one or all to build artifacts for corresponding platform
* -b<br>
When building AVR target (-a), this option specifies a target board. To see a complete list of the
boards supported by arduino-sdk, uncomment instruction "print_board_list()" in
[example/avr/CMakeLists.txt](#avr_CMakeLists.txt)
* -c<br>
Some AVR boards have different CPUs (e.g. mega), -c option specifies which CPU the board uses
* -u - clone/pull dependencies from github<br>
When specified, the script will try to pull the changes for the above libraries from github.
Alternatively, module [project_setup.cmake](#project_setup.cmake) can achieve similar
goal but as part of the building process

#### <a name="CMakeLists.txt" href="example/CMakeLists.txt">example/CMakeLists.txt</a>

When cmake is invoked, this CMakeLists.txt is the first file it loads. After the version and
project preamble, the file sets the path to modules and loads [init.cmake](#init.cmake), 
[firmware.cmake](#firmware.cmake) and [unit_testing.cmake](#unit_testing.cmake) modules:

```
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
include(init)
include(firmware)
include(unit_testing)
```

```$ENV{CMAKEHELPERS_HOME}``` is set in the environment to point to cmake-helpers (this)
project's root directory.

Now, when required variables and functions are made available, cmake determines what build it needs
to generate for the make tool to continue afterwards:

```cmake
function(add_target_config_args)
  add_target_config(
    SRC_DIR ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}
    BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY}
    TOOLCHAIN_FILE ${TOOLCHAIN_FILE}
  ...
endfunction()

string(COMPARE EQUAL "${BOARD_FAMILY}" stm32 _cmp)
if (_cmp)
  set(TOOLCHAIN_FILE $ENV{STM32CMAKE_HOME}/cmake/gcc_stm32.cmake)
  ...
  add_target_config_args(...)
  add_target_build(...)
  add_target_flash(...)

else ()

  string(COMPARE EQUAL "${BOARD_FAMILY}" avr _cmp)
  if (_cmp)
    set(TOOLCHAIN_FILE $ENV{ARDUINOCMAKE_HOME}/cmake/ArduinoToolchain.cmake)
    ...
    add_target_config_args(...)
    add_target_build(...)
    add_target_flash(...)

  else()

    string(COMPARE EQUAL "${BOARD_FAMILY}" x86 _cmp)
    if (_cmp)
      add_subdirectory(${PROJECT_SOURCE_DIR}/src/x86)
    endif ()
endif ()
```

When ```${BOARD_FAMILY}``` (passed by [make.sh](#make.sh)) matches one of the microcontroller
branches, avr or stm32, cmake configures cross-compilation project and adds two more targets,
build and flash. The functions are defined in [firmware.cmake](#firmware.cmake). Cmake then
switches to a different toolchain and builds the firmware as specified by target's respective
[avr/CMakeLists.txt](#avr_CMakeLists.txt) or [stm32/CMakeLists.txt](#stm32_CMakeLists.txt) file.


If unit tests were enabled or ```${BOARD_FAMILY}``` is x86, cmake keeps using the current
toolchain to build x86 sources located in ```${PROJECT_SOURCE_DIR}/src/x86``` and unit tests
located in ```${PROJECT_SOURCE_DIR}/test```.

#### <a name="avr_CMakeLists.txt" href="example/src/avr/CMakeLists.txt">example/src/avr/CMakeLists.txt</a>

Since main [CMakeLists.txt](#CMakeLists.txt) switched cmake to a different toolchain to build AVR
code, the global variables must be reinitialized except for those that were specifically passed to
this toolchain (see add_target_config in [firmware.cmake](#firmware.cmake)). That is the reason
for a regular preampble:

```cmake
cmake_minimum_required(VERSION 3.5)
project(${PROJECT_NAME})
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
include(init)
```

Note, ```${PROJECT_NAME}``` was passed in by prior cmake stage, but ```$ENV{CMAKEHELPERS_HOME}```
is still read from the environment.

Next, cmake executes usual instructions when setting up source files for compilation:
```cmake
include_directories(...)
add_definitions(-D${BOARD_FAMILY})
add_compile_options(-Wall -Wextra)
```

Here, cmake generates Arduino-specific instructions for building and flashing the firmware using
a function defined in
<a href="https://github.com/queezythegreat/arduino-cmake.git" target="_blank">arduino-cmake</a>
```cmake
generate_arduino_firmware(...)
```

#### <a name="stm32_CMakeLists.txt" href="example/src/stm32/CMakeLists.txt">example/src/stm32/CMakeLists.txt</a>


#### <a name="x86_CMakeLists.txt" href="example/src/x86/CMakeLists.txt">example/src/x86/CMakeLists.txt</a>


#### <a name="init.cmake" href="cmake/Modules/init.cmake">init.cmake</a>

Initializes common variables such as verbosity, build type, c++ standard, unit testing, etc.

#### <a name="gtest.cmake" href="cmake/Modules/gtest.cmake">gtest.cmake</a>

Adds gtest project as part of a current build

#### <a name="project_setup.cmake" href="cmake/Modules/project_setup.cmake">project_setup.cmake</a>

Sets up external projects

#### <a name="project_download.cmake.in" href="cmake/Modules/project_download.cmake.in">project_download.cmake.in</a>

Provides cmake template for importing external projects from a github repository

#### <a name="unit_testing.cmake" href="cmake/Modules/unit_testing.cmake">unit_testing.cmake</a>

Enables unit testing and adds subdirectory containing the tests

#### <a name="firmware.cmake" href="cmake/Modules/firmware.cmake">firmware.cmake</a>

When cross-compiling on a host x86 platform for a target AVR or STM32 platform, the module sets
up a build environment (gcc, libs, etc.) suitable to build binaries for a given target.

 portable code.

#### <a name="freertos.cmake" href="cmake/Modules/freertos.cmake">freertos.cmake</a>

Sets up FreeRTOS source/header files and directories, heap configuration

#### <a name="stm32f103c8t6.cmake" href="cmake/Modules/stm32f103c8t6.cmake">stm32f103c8t6.cmake</a>

Configures variables for building stm32f103 firmware

# <a name="Contribute"></a>Contribute

Consider supporting our projects by contributing to their development.
<a href="https://boltrobotics.com/contribute/" target="_blank">Learn more at boltrobotics.com</a>
