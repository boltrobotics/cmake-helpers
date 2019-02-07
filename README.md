# Introduction

The repository contains Cmake modules and example files which help to save time when
setting up new C/C++ projects. The main goal is to reuse working solutions to common
problems such as:

* Combining of cross-compilation for AVR / STM32F103 with unit testing on x86 platform
* Downloading and refreshing of dependencies
* Setting up paths to headers, sources and libraries
* Re-typing boilerplate code around initialization and checks
* Cluttering build files with large, duplicated blocks of instructions
* Recurrent research and refresh of information about Cmake

### Platforms and requirements

The [example](#Example) project was tested on MacOS and Linux. Depending on host and target
platforms, not all the dependencies given below may apply.

Most of the packages can be installed using system package manager or supplemental tools like
brew on MacOS. When a package manager doesn't support a package, the package is downloaded from
GitHub (for example, gtest, stm32-cmake) or directly from developer's website (for example,
Arm GNU Embedded Toolchain, FreeRTOS).

* x86 software/host platform
  * <a href="https://en.wikipedia.org/wiki/Xcode" target="_blank">Xcode (MacOS)</a>
  * build-essential (Linux)
  * <a href="https://cmake.org/" target="_blank">Cmake</a>
  * <a href="https://www.boost.org/" target="_blank">Boost</a>
  * <a href="https://github.com/google/googletest.git" target="_blank">Google Test</a>
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
  * [main_project.cmake](#main_project.cmake)
  * [example/src/avr/CMakeLists.txt](#avr_CMakeLists.txt)
  * [avr_project.cmake](#avr_project.cmake)
  * [example/src/stm32/CMakeLists.txt](#stm32_CMakeLists.txt)
  * [stm32_project.cmake](#stm32_project.cmake)
  * [example/src/x86/CMakeLists.txt](#x86_CMakeLists.txt)
  * [x86_project.cmake](#x86_project.cmake)
  * [example/test/CMakeLists.txt](#unit_CMakeLists.txt)
  * [test_project.cmake](#test_project.cmake)
  * [gtest.cmake](#gtest.cmake)
  * [init.cmake](#init.cmake)
  * [unit_testing.cmake](#unit_testing.cmake)
  * [project_setup.cmake](#project_setup.cmake)
  * [project_download.cmake.in](#project_download.cmake.in)
  * [firmware.cmake](#firmware.cmake)
  * [libopencm3.cmake](#libopencm3.cmake)
  * [freertos.cmake](#freertos.cmake)
  * [stm32f103c8t6.cmake](#stm32f103c8t6.cmake)
* [Contribute](#Contribute)

# <a name="Example"></a>Example

Directory ["example"](example/) represents an example cross-compilation project. Within it:

* src/avr/main.cpp <br>
  Uses Arduino library to blink a built-in LED and call a function Example::hello() while running
  on AVR-based microcontroller
* src/stm32/main.cpp <br>
  Uses libopencm3 and FreeRTOS to start a task which blinks a built-in LED and calls Example::hello()
  while running on STM32F103C8 microcontroller (aka
  <a href="https://wiki.stm32duino.com/index.php?title=Blue_Pill" target="_blank">Blue Pill</a>)
* src/x86/main.cpp <br>
  Calls Example::hello() while running on MacOS or Linux

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

To start cmake build, the project provides bash script [make.sh](#make.sh).
For example, to build programs for all three platforms, run:
```
./make.sh -x -s -a -b mega -c atmega2560 -p /dev/ttyACM0 -- -DENABLE_TESTS=ON
```

The script creates the following three directories. Cmake then generates the builds
for corresponding toolchains within them. Lastly, make tool initiates the build in
each of the directories:
```
example/
|-- ...
|-- build-avr
|-- build-stm32
|-- build-x86
|-- ...
```

To upload just-built firmware to a connected board, change into ```build-avr``` or
```build-stm32``` and execute:

```bash
make example-flash
```

To run an example unit test which is defined in ```test/example_test.cpp```, change into
```build-x86``` and execute:
```
make test
```

# <a name="Details"></a>Details

### <a href=example/make.sh name="make.sh">example/make.sh</a>

The script makes it convenient to set up the environment and pass the required parameters to cmake
program.

Example project and Cmake modules use specific variables from the environment. One such set
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
        -u - clone/pull dependencies from GitHub
        -h - this help
```

* -x, -s, -a<br>
Specify one or all options to build artifacts for the corresponding platform
* -b <br>
When building for AVR platform (-a), this option specifies a target board. To see a complete list of
the boards supported by arduino-sdk, uncomment instruction "print_board_list()" in
[example/avr/CMakeLists.txt](#avr_CMakeLists.txt)
* -c <br>
Some AVR boards have different CPUs (e.g. mega), -c option specifies which CPU the board uses.
ArduinoToolchain will offer suggestions when it requires that parameter
* -p <br>
Specify a serial port where AVR device is connected to
* -u <br>
When specified, the script will try to pull the changes for the above libraries from GitHub.
Alternatively, module [project_setup.cmake](#project_setup.cmake) can achieve similar
goal but as part of the building process

### <a name="CMakeLists.txt" href="example/CMakeLists.txt">example/CMakeLists.txt</a>
Cmake processes this file first. It sits at the project's root and sets a couple of general 
parameters and then loads the common code for statring cross-compiled project from
[main_project.cmake](#main_project.cmake):

```cmake
project(example)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
set(ROOT_SOURCE_DIR ${PROJECT_SOURCE_DIR})
include(main_project)
```

### <a name="main_project.cmake" href="main_project.cmake">main_project.cmake</a>

Instructions in the file start with a regular version/project preamble. Next, the file sets
the path to modules and instructs to include [init.cmake](#init.cmake),
[firmware.cmake](#firmware.cmake) and [unit_testing.cmake](#unit_testing.cmake) modules:

```cmake
cmake_minimum_required(VERSION 3.5)
project(example)

set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
include(init)
include(firmware)
include(unit_testing)
```

```$ENV{CMAKEHELPERS_HOME}``` is set in the environment to point to cmake-helpers (this)
project's root directory.

Now, when the modules are processed, cmake determines what build it needs to generate based on
```${BOARD_FAMILY}``` (initialized in [init.cmake](#init.cmake)):

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

Cmake follows one of three decision branches for generating avr, stm32 or x86 build.

Functions add_target_confg(), add_target_build(), add_target_flash() are defined in
[firmware.cmake](#firmware.cmake). 

If ```${BOARD_FAMILY}``` matches a microcontroller branch (avr or stm32), cmake switches the
toolchain and generates a cross-compilation build based on the instructions in
[avr/CMakeLists.txt](#avr_CMakeLists.txt) or [stm32/CMakeLists.txt](#stm32_CMakeLists.txt).

If ```${BOARD_FAMILY}``` matches x86 or unit tests were enabled with -DENABLE_TESTS=ON, cmake
continues to use the current x86 toolchain to generate the build based on
[x86/CMakeLists.txt](#x86_CMakeLists.txt) and unit tests based on
[test/CMakeLists.txt](#unit_CMakeLists.txt).

### <a name="avr_CMakeLists.txt" href="example/src/avr/CMakeLists.txt">example/src/avr/CMakeLists.txt</a>

In order to build firmware with a different toolchain, cmake "re-initializes" the build with that 
new toolchain. Because of that, previously defined variables and functions must also be
reinitialized except for those that were specifically passed in by the preceeding stage.
These common tasks and more reside in [avr_project.cmake](#avr_project.cmake)

Example CMakeLists.txt instructs to build an executable with ```set(BUILD_EXE ON)```:

```cmake
cmake_minimum_required(VERSION 3.5)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)

if (NOT BUILD_LIB AND NOT BUILD_EXE)
  set(BUILD_LIB OFF)
  set(BUILD_EXE ON)
endif ()

include(avr_project)
```

### <a name="avr_project.cmake" href="cmake/Modules/avr_project.cmake">avr_project.cmake</a>

First, the module sets a project name: 

```cmake
if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

include(init)
```

Next, cmake executes usual instructions when setting up source files for compilation:

```cmake
include_directories(...)
file(GLOB_RECURSE SOURCES ...)
add_definitions(-D${BOARD_FAMILY})
...
```

Here, cmake generates Arduino-specific instructions for building and flashing the firmware using
functions defined in
<a href="https://github.com/queezythegreat/arduino-cmake.git" target="_blank">arduino-cmake</a>:
```cmake
if (BUILD_LIB)
  generate_arduino_library(...)
...
if (BUILD_EXE)
  generate_arduino_firmware(...)
...
```

### <a name="stm32_CMakeLists.txt" href="example/src/stm32/CMakeLists.txt">example/src/stm32/CMakeLists.txt</a>

This project file uses the same idea as described in [avr/CMakeLists.txt](#avr_CMakeLists.txt), but
here more instructions need to be specified.

The firmware for stm32f103c8 depends on
<a href="https://github.com/libopencm3/libopencm3.git" target="_blank">libopencm3</a> library.
Before the firmware can use it, libopencm3 must be built using ```make```. One option to achieve it
is to download and build the library manually. Another is to use
[project_setup.cmake](#project_setup.cmake) module which can automate the process a bit more.

Another library that the firmware depends on is
<a href="https://www.freertos.org/" target="_blank">FreeRTOS</a>, which has its own usage
requirements. See [freertos.cmake](#freertos.cmake) for details.

```
set(BUILD_LIB OFF)
set(BUILD_EXE ON)
...
include(stm32f103c8t6)
include(libopencm3)
include(freertos)
...
include(stm32_project)
```

### <a name="stm32_project.cmake" href="cmake/Modules/stm32_project.txt">stm32_project.cmake</a>

Most of what is described in [avr_project.cmake](#avr_project.cmake) applies here, but instead
Cmake executes stm32-specific instructions defined in
<a href="https://github.com/boltrobotics/stm32-cmake.git" target="_blank">stm32-cmake</a> toolchain:

```cmake
if (BUILD_EXE)
  set(TARGET ${PROJECT_NAME}${EXE_SUFFIX})
  add_executable(${TARGET} ${MAIN_SRC} ${SOURCES})
...
STM32_SET_TARGET_PROPERTIES(...)
STM32_ADD_HEX_BIN_TARGETS(...)
...
```

### <a name="x86_CMakeLists.txt" href="example/src/x86/CMakeLists.txt">example/src/x86/CMakeLists.txt</a>

The file instructs to build a library, an executable, and link the executable with the library:

```
set(BUILD_LIB ON)
set(BUILD_EXE ON)
set(EXE_SUFFIX "-exe")

set(LIB_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
set(EXE_LIBRARIES ${PROJECT_NAME})

include(x86_project)
```

```EXE_SUFFIX``` is required because x86_project tries to use ```${PROJECT_NAME}``` for both library
and executable targets.

### <a name="x86_project.cmake" href="cmake/Modules/x86_project.txt">x86_project.cmake</a>

The module is similar in structure and purpose to [avr_project.cmake](#avr_project.cmake) and
[stm32_project.cmake](#stm32_project.cmake), but the build target is x86 platform.

### <a name="unit_CMakeLists.txt" href="example/test/CMakeLists.txt">example/test/CMakeLists.txt</a>

The file specifies what to link unit testing executable with and loads
[test_project.cmake](#test_project.cmake):
```
set(EXE_LIBRARIES ${PROJECT_NAME})
set(EXE_SUFFIX "-tests")
include(test_project)
```

### <a name="test_project.cmake" href="cmake/Modules/test_project.txt">test_project.cmake</a>

Instructions ini this file are similar to [x86_project.cmake](#x86_project.cmake), except only
an executable is needed which should be linked with google test and Boost libraries:

```
include(gtest)
...
add_executable(${PROJECT_NAME}${EXE_SUFFIX} ${SOURCES})
...
target_link_libraries(${PROJECT_NAME}${EXE_SUFFIX}
  ${EXE_LIBRARIES} ${gtest_LIB_NAME} ${Boost_LIBRARIES})
```

### <a name="gtest.cmake" href="cmake/Modules/gtest.cmake">gtest.cmake</a>

Per instructions in this file, cmake checks if googletest and its dependency (Boost) are already
installed. If not, cmake uses [project_setup.cmake](#project_setup.cmake) to download the
googletest sources from GitHub and add subdirectory with the content to the unit test build.
If ```REQUIRED``` Boost libraries are not found, cmake will stop the build.

```cmake
set(GTEST_HOME $ENV{GTEST_HOME})
find_package(Boost REQUIRED COMPONENTS system thread)
find_package(GTest)
...
add_project(
  PREFIX gtest
  URL "https://github.com/google/googletest.git"
  HOME "${GTEST_HOME}"
  INC_DIR "${GTEST_HOME}/googletest/include")
...
```

### <a name="init.cmake" href="cmake/Modules/init.cmake">init.cmake</a>

The file checks and initializes common variables if undefined:
* BOARD_FAMILY
* CMAKE_BUILD_TYPE
* EXECUTABLE_OUTPUT_PATH
* LIBRARY_OUTPUT_PATH
* CMAKE_CXX_STANDARD
* CMAKE_RULE_MESSAGES
* CMAKE_VERBOSE_MAKEFILE
* LIB_TYPE

### <a name="unit_testing.cmake" href="cmake/Modules/unit_testing.cmake">unit_testing.cmake</a>

The module checks if the platform is x86 and enables unit testing if ```${ENABLE_TESTS}``` option
is set to ON. The option can be passed via [make.sh](#make.sh) (see [Example](#Example)).

### <a name="project_setup.cmake" href="cmake/Modules/project_setup.cmake">project_setup.cmake</a>

The module is used to set up external cmake/make project for use by a current project. It involves:
* downloading the files from external source such as GitHub
* exporting of source, header and/or built library names and locations
* adding targets, which are defined by the external project, to global scope. To see all available
targets after cmake completes, change into one of build-\* directories and type: ```make help```

Note, project_setup uses <a href="https://cmake.org/cmake/help/latest/module/ExternalProject.html"
target="_blank">ExternalProject</a> module. Many concepts can be clarified by reading that module's
documentation.

As an example, [libopencm3.cmake](#libopencm3.cmake) uses add_project() to set up external project:

```cmake
include(project_setup)

set(LIBOPENCM3_HOME $ENV{LIBOPENCM3_HOME})

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
add_project(
  PREFIX libopencm3
  HOME "${LIBOPENCM3_HOME}"
  URL "https://github.com/libopencm3/libopencm3.git"
  BUILD_CMD "make TARGETS=stm32/${STM32_FAMILY_LOWER} VERBOSE=1"
  BUILD_IN 1
  FORCE_UPDATE 0
  LIB_DIR "${LIBOPENCM3_HOME}/lib"
  LIB_NAME opencm3_stm32${STM32_FAMILY_LOWER})

include_directories(${libopencm3_INC_DIR})
link_directories(${libopencm3_LIB_DIR})
list(APPEND LIBRARIES ${libopencm3_LIB_NAME})
```

* PREFIX is prepended to the names of external project's artifacts. For example, in order to
refer to libopencm3 include directory, cmake would use ```${libopencm3_INC_DIR}```
* HOME is a directory of where to look for the project before trying to download it. If the
directory doesn't exist or FORCE_UPDATE is set to 1, add_project()  will try to download the
content into that location using download_project() function defined in the same module
* URL is a project's external location
* BUILD_CMD is a build command to execute
* BUILD_IN is used to build projects in-source
* LIB_DIR specifies of where the built library will be stored so as to export proper
```${${PREFIX}_LIB_DIR}``` location
* LIB_NAME is required if the project's library name is non-standard. Often a library can be
referred to (in Cmake) by project's name, i.e. ```${PREFIX}```. In case of libopencm3, the
library name for use with stm32f103c8t6 board is ```libopencm3_stm32f1.a```

### <a name="project_download.cmake.in" href="cmake/Modules/project_download.cmake.in">project_download.cmake.in</a>

When setting up new external project using [project_setup.cmake](#project_setup.cmake), this Cmake
template is used to generate instructions for downloading and building that project:

```cmake
include(ExternalProject)
ExternalProject_Add(${PREFIX}
  GIT_REPOSITORY    ${URL}
  GIT_TAG           master
  ${SOURCE_DIR}
  ${BINARY_DIR}
  ${CONFIG_CMD}
  ${BUILD_CMD}
  ${BUILD_IN}
  ${INSTALL_CMD}
  ${TEST_CMD}
  ${LOG_BUILD}
)
```

### <a name="firmware.cmake" href="cmake/Modules/firmware.cmake">firmware.cmake</a>

The module defines three functions:
* add_target_config() configures a new cmake environment to be executed with a different toolchain
* add_target_build() adds a custom target to start cross-compilation by using
```make _project_name_```
* add_target_flash() adds a custom target to upload the built firmware to the target board; to be
invoked with ```make _project_name_-flash```

### <a name="libopencm3.cmake" href="cmake/Modules/libopencm3.cmake">libopencm3.cmake</a>

The file uses [project_setup.cmake](#project_setup.cmake) to set up external project dependency.

### <a name="freertos.cmake" href="cmake/Modules/freertos.cmake">freertos.cmake</a>

The module helps to set up <a href="https://www.freertos.org/" target="_blank">FreeRTOS</a>
source/header file locations to be included as part of the build for stm32f103c8t6 board.

See <a href="https://www.freertos.org/Documentation/RTOS_book.html" target="_blank">FreeRTOS
documentation</a> for details about this interesting OS.

### <a name="stm32f103c8t6.cmake" href="cmake/Modules/stm32f103c8t6.cmake">stm32f103c8t6.cmake</a>

The module aggregates compiler and linker flags which are required to build firmware for
stm32f103c8t6.

To some degree, this module defeats the purpose of using
<a href="https://github.com/boltrobotics/stm32-cmake.git" target="_blank">stm32-cmake</a>.
Moreover, most features of stm32-cmake remain unused and may cause difficulty during the build.
A few functions that [stm32/CMakeLists.txt](#stm32_CMakeLists.txt) refers to do not justify
keeping that dependency around. ```TODO``` reassess the benefit of using stm32-cmake given the
circumstances.

# <a name="Contribute" href="https://boltrobotics.com/contribute/" target="_blank">Contribute</a>

Consider supporting our projects by contributing to their development.
<a href="https://boltrobotics.com/contribute/" target="_blank">Learn more at boltrobotics.com</a>
