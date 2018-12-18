# cmake-helpers
Cmake modules containing common functionality between projects

# Table of Contents

* [firmware.cmake](#firmware.cmake)
* [freertos.cmake](#freertos.cmake)
* [gtest.cmake](#gtest.cmake)
* [init.cmake](#init.cmake)
* [project_download.cmake.in.cmake](#project_download.in.cmake)
* [project_setup.cmake.cmake](#project_setup.cmake)
* [stm32f103c8t6.cmake.cmake](#stm32f103c8t6.cmake)
* [unit_test.cmake.cmake](#unit_test.cmake)

## <a name="firmware.cmake"></a>firmware.cmake
Adds custom targets for building STM32 blue/black pill firmware with st-flash
## <a name="freertos.cmake"></a>freertos.cmake
Sets up FreeRTOS source/header files and directories, heap configuration
## <a name="gtest.cmake"></a>gtest.cmake
Adds gtest project as part of a current build
## <a name="init.cmake"></a>init.cmake
Initializes common variables such as verbosity, build type, c++ standard, unit testing, etc.
## <a name="project_download.in.cmake"></a>project_download.in.cmake
Provides cmake template for importing external projects from a github repository
## <a name="project_setup.cmake"></a>project_setup.cmake
Sets up external projects
## <a name="stm32f103c8t6.cmake"></a>stm32f103c8t6.cmake
Configures variables for building stm32f103 firmware
## <a name="unit_testing.cmake"></a>unit_testing.cmake
Enables unit testing and adds subdirectory containing the tests
