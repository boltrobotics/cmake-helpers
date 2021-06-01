cmake_minimum_required(VERSION 3.16)
project(example)

include(stm32_project)
setup_stm32()
find_srcs()

####################################################################################################
# libopencm3 {

include(libopencm3)
include_directories(${libopencm3_INC_DIR})
link_directories(${libopencm3_LIB_DIR})
list(APPEND LIBS ${libopencm3_LIB_NAME})

# } libopencm3

####################################################################################################
# FreeRTOS {

include(freertos)
include_directories(${FREERTOS_INC_DIRS})
list(APPEND SOURCES ${FREERTOS_SOURCES})

# } FreeRTOS

####################################################################################################
# Build executable {

build_exe(SRCS ${SOURCES} LIBS ${LIBS})

# } Build executable
