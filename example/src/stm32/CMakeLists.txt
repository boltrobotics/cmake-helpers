cmake_minimum_required(VERSION 3.5)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)

set(BUILD_LIB OFF)
set(BUILD_EXE ON)

include(stm32f103c8t6)

####################################################################################################
# libopencm3 {

include(libopencm3)
include_directories(${libopencm3_INC_DIR})
link_directories(${libopencm3_LIB_DIR})
list(APPEND EXE_LIBRARIES ${libopencm3_LIB_NAME})

# } libopencm3

####################################################################################################
# FreeRTOS {

include(freertos)
include_directories(${FREERTOS_INC_DIRS})
list(APPEND SOURCES ${FREERTOS_SOURCES})

# } FreeRTOS

include(stm32_project)
