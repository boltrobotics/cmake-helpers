Cmake helper modules help to create cross-compiled builds for x86, ESP32, STM32, and AVR. The goal
was to reuse working solutions from different projects and reduce duplicate work such as:

* Setting up paths to source files and libraries
* Enabling of unit testing on x86 platform for embedded platform code 
* Re-typing boilerplate code around initialization and checks

## Platforms and requirements

Most of the dependent packages can be installed using system package manager. When a package
manager doesn't support a dependency, the package is downloaded from GitHub (for example, gtest)
or directly from a developer's website (for example, Arm GNU Embedded Toolchain, FreeRTOS).

* x86 software/host platform
  * build-essential (Linux)
  * <a href="https://cmake.org/" target="_blank">CMake</a>
  * <a href="https://www.boost.org/" target="_blank">Boost</a>
  * <a href="https://github.com/google/googletest.git" target="_blank">Google Test</a>
  * <a href="https://github.com/gabime/spdlog" target="_blank">Fast C++ logging library</a>
* To build ESP32 firmware
  * <a href="https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html" target="_blank">ESP-IDF</a>
* To build STM32F103 firmware
  * <a href="https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm" target="_blank">Arm GNU Embedded Toolchain</a>
  * <a href="https://github.com/libopencm3/libopencm3.git" target="_blank">libopencm3</a>
  * <a href="https://www.freertos.org/" target="_blank">FreeRTOS</a>
  * st-link tool
* To build AVR firmware
  * avr-gcc
  * <a href="https://www.nongnu.org/avrdude/" target="_blank">avrdude</a>

# Table of Contents

* [Example](#Example)
* [Details](#Details)
  * [example/make.sh](#make.sh)
  * [example/CMakeLists.txt](#CMakeLists.txt)
  * [main_project.cmake](#main_project.cmake)
  * [example/src/avr/CMakeLists.txt](#avr_CMakeLists.txt)
  * [example/src/esp32/CMakeLists.txt](#esp32_CMakeLists.txt)
  * [example/src/stm32/CMakeLists.txt](#stm32_CMakeLists.txt)
  * [example/src/x86/CMakeLists.txt](#x86_CMakeLists.txt)
  * [example/test/CMakeLists.txt](#unit_CMakeLists.txt)
  * [init.cmake](#init.cmake)
  * [project_setup.cmake](#project_setup.cmake)
  * [project_download.cmake.in](#project_download.cmake.in)
  * [firmware.cmake](#firmware.cmake)

# <a name="Example"></a>Example

Directory ["example"](example/) contains a simulated cross-compilation
project. Within it:

* src/avr/main.cpp <br>
  Uses AVR-based microcontroller to blink a built-in LED and call a function Example::hello()
* src/esp32/main.cpp <br>
  Prints information about the chip, restarts, and keeps repeating the same.
* src/stm32/main.cpp <br>
  Uses libopencm3 and FreeRTOS to start a task which blinks a built-in LED and calls
  Example::hello() while running on STM32F103C8 microcontroller
* src/x86/main.cpp <br>
  Calls Example::hello() while running on MacOS or Linux

### Project Structure

Cloned repository contains this directory branch with an example project:

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
    |-- esp32
        |-- CMakeLists.txt
        |-- main.cpp
        |-- sdkconfig.defaults
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

### Building

[make.sh](#make.sh) is used to start cmake build. To build binaries for supported platforms
and unit tests, run:

```
cd example
./make.sh -x -e -s -a -t
```

The script creates a separate output directory per platform and then calls cmake:

```
example/
|-- ...
|-- build-avr
|-- build-esp32
|-- build-stm32
|-- build-x86
|-- ...
```

### Testing

To run an example unit test (defined in <i>test/example_test.cpp</i>), first run make.sh with -x
and -t options, then:

```bash
cd build-x86
ninja test
```

### Uploading

Once the build is complete, upload the firmware from within the target platform directory. For
example, for AVR:

```bash
cd build-avr
ninja example-flash
```

<a name="Details"></a>
# Details

The following sections describe the functionality in a context of the example project.

<a name="make.sh"></a>
### <a href="example/make.sh">example/make.sh</a>

The script makes it convenient to set up the environment and pass the required parameters to cmake.
The parameters include project's home, cmake-helpers' home, locations of dependent
libraries, and target platforms for which to build the project. Change dependencies in the
script to adapt it to other projects

```bash
if [ -z ${XTRA_HOME} ]; then
  XTRA_HOME=${PWD}/../xtra
fi

export GTEST_HOME=${XTRA_HOME}/gtest
export LIBOPENCM3_HOME=${XTRA_HOME}/libopencm3
export FREERTOS_HOME=${XTRA_HOME}/FreeRTOSv10.1.1
```

Command line options:

```bash
Usage: make.sh [-x] [-a] [-s] [-e] [-d] [-c] [-v] [-t] [-h]
  -x - build x86
  -s - build stm32 (board stm32f103c8t6)
  -e - build esp32
  -a - build avr
  -d - clone or pull dependencies
  -c - export compile commands
  -v - enable verbose output
  -t - enable unit tests
  -h - this help
```

* -x, -s, -e, -a<br>
The flags indicate which platform to build for. Multiple options can be specified.
* -d <br>
The flag instructs to clone or pull changes for dependent libraries from GitHub.
* -c <br>
Enables CMAKE_EXPORT_COMPILE_COMMANDS for troubleshooting.
* -v <br>
Enables CMAKE_VERBOSE_MAKEFILE for verbose output during the build.
* -t <br>
The flag instructs to build unit tests. Must also specify "-x" to run on x86.

<a name="CMakeLists.txt"></a> 
### <a href="example/CMakeLists.txt">example/CMakeLists.txt</a>

The file sets up project's name, root directory and module path. It then tells cmake to process
the code for starting cross-compiled project in [main_project.cmake](#main_project.cmake):

```cmake
project(example)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
set(ROOT_SOURCE_DIR ${PROJECT_SOURCE_DIR})
include(main_project)
```

<a name="avr_CMakeLists.txt"></a>
### <a href="example/src/avr/CMakeLists.txt">example/src/avr/CMakeLists.txt</a>

Cmake processes this file after it determined to build for AVR in
[main_project.cmake](#main_project.cmake). To build the firmware, cmake re-initializes the
environment with GCC AVR toolchain, which specifies its own build parameters and procedures.
These instructions are given in <a href="cmake/Modules/avr_project.cmake">
avr_project.cmake</a>.

See <a href="cmake/Modules/gcc_avr_toolchain.cmake">gcc_avr_toolchain.cmake</a>
for AVR compiler and linker flags for AVR boards.

Here, CMakeLists.txt instructs to set up for a specific AVR board connected to some port, and
that it needs to build an executable:

```cmake
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
set(AVR_MCU atmega168)
set(AVR_UPLOADTOOL_PORT "/dev/tty.usbmodemFD14511")

include(avr_project)
setup_avr()
find_srcs()
build_exe(SRCS ${SOURCES})
```

<a name="esp32_CMakeLists.txt"></a>
### <a href="example/src/esp32/CMakeLists.txt">example/src/esp32/CMakeLists.txt</a>

Similar logic described for AVR applies to ESP32 projects.

* <a href="cmake/Modules/esp32_project.cmake">esp32_project.cmake</a> defines building
  instructions for ESP32 binaries. The instructions refer to ESP-IDF toolchain.

```
include(esp32_project)
find_srcs()

build_exe(
  SRCS ${SOURCES}
  ESP_TARGET ${ESP_TARGET}
  LIBS idf::freertos idf::spi_flash
  COMPONENTS freertos esptool_py
  )
```

<a name="stm32_CMakeLists.txt"></a>
### <a href="example/src/stm32/CMakeLists.txt">example/src/stm32/CMakeLists.txt</a>

Similar logic described for AVR applies to STM32 project. There are additional steps that
cmake goes through due to extra dependencies.

* <a href="cmake/Modules/stm32_project.cmake">stm32_project.cmake</a> defines building
  instructions for STM32 binaries
* <a name="gcc_stm32_toolchain.cmake" href="cmake/Modules/gcc_stm32_toolchain.cmake">
  gcc_stm32_toolchain.cmake</a> aggregates compiler and linker flags for cross-compiling code for 
  stm32f103c8t6
* <a href="https://github.com/libopencm3/libopencm3.git">libopencm3</a> is a C library and must be
  built using _make_. One option to achieve it is to download and build the
  library manually. Another option is to use [project_setup.cmake](#project_setup.cmake) module,
  which can automate the process a bit more
* <a href="https://www.freertos.org/Documentation/RTOS_book.html">FreeRTOS</a> is
  a real-time embedded OS. The parameters related to it are defined in <a name="freertos.cmake"
  href="cmake/Modules/freertos.cmake">freertos.cmake</a>

```
include(stm32_project)
find_srcs()
...
include(libopencm3)
...
include(freertos)
...
build_exe(SRCS ${SOURCES} LIBS ${LIBS})
```

<a name="x86_CMakeLists.txt" ></a>
### <a href="example/src/x86/CMakeLists.txt">example/src/x86/CMakeLists.txt</a>

The file instructs cmake to build library/executable for x86 platform. The required parameters
are defined in <a href="cmake/Modules/x86_project.cmake">x86_project.cmake</a>:

```
include(x86_project)
setup_x86()
...
find_srcs(FILTER ${MAIN_SRC})
build_lib(SRCS "${SOURCES}" LIBS ${CMAKE_THREAD_LIBS_INIT})
build_exe(OBJS "${SOURCES_OBJ}" SRCS "${MAIN_SRC}" LIBS ${PROJECT_NAME} SUFFIX "-exe")
```

<a name="unit_CMakeLists.txt" ></a>
### <a href="example/test/CMakeLists.txt">example/test/CMakeLists.txt</a>

The file tells cmake to build a test executable. The file's logic is the same as for building a
regular program:

```
include(x86_project)

find_test_srcs()
build_exe(SRCS ${SOURCES} LIBS ${PROJECT_NAME} SUFFIX "-tests")
```

Here, we don't call <i>setup_x86()</i> as x86 was already configured in
<a href="#main_project.cmake">main_project.cmake's</a> <em>else</em> branch as part of
<i>add_subdirectory("${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")</i>

The project is configured to use Google test framework. The framework is set up in
<a href="cmake/Modules/gtest.cmake">gtest.cmake</a> and is invoked from
<a href="cmake/Modules/x86_project.cmake">x86_project.cmake</a>

<a name="main_project.cmake" ></a>
### <a href="cmake/Modules/main_project.cmake">main_project.cmake</a>

Cmake initializes common parameters and procedures via [init.cmake](#init.cmake), and
[firmware.cmake](#firmware.cmake). It then determines which build to generate based on variables 
<i>${BTR_STM32}</i>, <i>${BTR_AVR}</i>, and <i>${BTR_X86}</i>, which are defined and passed by
[make.sh](#make.sh).

For ESP32/STM32/AVR platforms, cmake switches the toolchain and generates a cross-compilation build
based on the instructions in [esp32/CMakeLists.txt](#esp32_CMakeLists.txt),
[stm32/CMakeLists.txt](#stm32_CMakeLists.txt), [avr/CMakeLists.txt](#avr_CMakeLists.txt).
Otherwise, cmake continues with the current toolchain to generate the build based on
[x86/CMakeLists.txt](#x86_CMakeLists.txt) and unit tests based on
[test/CMakeLists.txt](#unit_CMakeLists.txt):

```cmake
include(init)
include(firmware)

function(add_target_config_args)
  add_target_config(
    SRC_DIR ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}
    BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY}
    TOOLCHAIN_FILE ${TOOLCHAIN_FILE}
  ...
endfunction()

if (BTR_STM32 GREATER 0)
  set(TOOLCHAIN_FILE $ENV{CMAKEHELPERS_HOME}/cmake/Modules/gcc_stm32_toolchain.cmake)
  ...
  add_target_config_args(...)
  add_target_build(...)
  add_target_flash(...)

elseif (BTR_ESP32 GREATER 0)
  set(TOOLCHAIN_FILE ${IDF_PATH}/tools/cmake/toolchain-${ESP_TARGET}.cmake)
  ... 
  add_target_config_args(...)
  add_target_build(...)
  add_target_flash(...)

elseif (BTR_AVR GREATER 0)
  set(TOOLCHAIN_FILE $ENV{CMAKEHELPERS_HOME}/cmake/Modules/gcc_avr_toolchain.cmake)
  ...
  add_target_config_args(...)
  add_target_build(...)
  add_target_flash(...)

else()
  ...
  add_subdirectory("${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")

  if (ENABLE_TESTS)
    if (EXISTS "${ROOT_SOURCE_DIR}/test")
      enable_testing()
      add_subdirectory(${ROOT_SOURCE_DIR}/test)
      ...
endif ()
```

Functions <i>add_target_confg(), add_target_build(), add_target_flash()</i> are defined in
<a href="#firmware.cmake">firmware.cmake</a>.

<a name="init.cmake" ></a>
### <a href="cmake/Modules/init.cmake">init.cmake</a>

The file checks and initializes common variables if undefined, for example
CMAKE_BUILD_TYPE, EXECUTABLE_OUTPUT_PATH, LIBRARY_OUTPUT_PATH, CMAKE_RULE_MESSAGES

<a name="project_setup.cmake" ></a>
### <a href="cmake/Modules/project_setup.cmake">project_setup.cmake</a>

The module is used to set up external cmake/make project. It involves:

* exporting of source, header and/or built library names and locations
* adding targets, which are defined by the external project, to global scope
* downloading the files from external source such as GitHub

For example, <a href="cmake/Modules/libopencm3.cmake">libopencm3.cmake</a> uses
<i>add_project()</i> to set up an external project:

```cmake
include(project_setup)

set(LIBOPENCM3_HOME $ENV{LIBOPENCM3_HOME})

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
add_project(
  PREFIX libopencm3
  HOME "${LIBOPENCM3_HOME}"
  SRC_DIR "${LIBOPENCM3_HOME}"
  URL "https://github.com/libopencm3/libopencm3.git"
  BUILD_CMD "make TARGETS=stm32/${STM32_FAMILY_LOWER} VERBOSE=1"
  BUILD_IN 1
  FORCE_UPDATE $ENV{FORCE_UPDATE}
  LIB_DIR "${LIBOPENCM3_HOME}/lib"
  LIB_NAME opencm3_stm32${STM32_FAMILY_LOWER})

include_directories(${libopencm3_INC_DIR})
```

* _PREFIX_ is prepended to the names of external project's artifacts. For example, in order to
  refer to _libopencm3_ include directory, cmake would use <i>${libopencm3_INC_DIR}</i>
* _HOME_ is a directory of where to look for the project before trying to download it. If the
  directory doesn't exist or <i>FORCE_UPDATE</i> is set to 1, <i>add_project()</i>  will try to
  download the content into that location using <i>download_project()</i> function defined in the
  same module
* <i>SRC_DIR</i> is a root directory of the source files
* _URL_ is a project's external location
* <i>BUILD_CMD</i> is a build command to execute
* <i>BUILD_IN</i> is used to build projects in-source
* <i>LIB_DIR</i> specifies of where the built library will be stored so as to export proper
  <i>${${PREFIX}_LIB_DIR}</i> location
* <i>LIB_NAME</i> is required if the project's library name is non-standard. Often a library can be
  referred to in cmake by project's name, i.e. _${PREFIX}_. In case of libopencm3, static
  library name for use with stm32f103c8t6 board is <i>libopencm3_stm32f1.a</i>

<a name="project_download.cmake.in" ></a>
### <a href="cmake/Modules/project_download.cmake.in">project_download.cmake.in</a>

When setting up a new external project using [project_setup.cmake](#project_setup.cmake), this
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

<a name="firmware.cmake" ></a>
### <a href="cmake/Modules/firmware.cmake">firmware.cmake</a>

The module defines three functions:

* <i>add_target_config()</i> configures a new cmake environment to be executed with a different
  toolchain
* <i>add_target_build()</i> adds a custom target to start cross-compilation when using:
  ```bash 
  make _project_name_
  ```
* <i>add_target_flash()</i> adds a custom target to upload the binary to the target board. To
  initiate the upload, use:
  ```bash
  make _project_name_-flash
  ```
