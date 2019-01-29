cmake_minimum_required(VERSION 3.5)
project(${PROJECT_NAME})

set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
include(init)
include(project_setup)
include(stm32f103c8t6)

####################################################################################################
# libopencm3 {

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

# } libopencm3

####################################################################################################
# FreeRTOS {

include(freertos)
include_directories(${FREERTOS_INC_DIRS})
list(APPEND SOURCES ${FREERTOS_SOURCES})

# } FreeRTOS

####################################################################################################
# Firmware {

include_directories(
  ${MAIN_SOURCE_DIR}/src/${BOARD_FAMILY}
  ${MAIN_SOURCE_DIR}/src/common
  ${MAIN_SOURCE_DIR}/include
)

file(GLOB_RECURSE COMMON_SRC "${MAIN_SOURCE_DIR}/src/common/*.c*")
file(GLOB_RECURSE BOARD_SRC  "${MAIN_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c*")
list(APPEND SOURCES ${COMMON_SRC} ${BOARD_SRC})

add_definitions(-DSTM32${STM32_FAMILY} -D${BOARD_FAMILY})

add_executable(${PROJECT_NAME} ${SOURCES})
target_link_libraries(${PROJECT_NAME} ${LIBRARIES})

# Sets -DSTM32F1 -DSTM32F103xB, -T<linker_script>.
# Note linker script is copied and renamed to "PROJECT_NAME_flash.ld"
STM32_SET_TARGET_PROPERTIES(${PROJECT_NAME})
STM32_ADD_HEX_BIN_TARGETS(${PROJECT_NAME})
STM32_PRINT_SIZE_OF_TARGETS(${PROJECT_NAME})

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} --build .
  --target ${PROJECT_NAME}.bin)
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} --build .
  --target ${PROJECT_NAME}.hex)

print_compile_flags()

# } Firmware
