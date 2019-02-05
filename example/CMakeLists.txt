cmake_minimum_required(VERSION 3.5)
project(example)

set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
include(init)
include(firmware)

####################################################################################################
# unit testing, x86 {

include(unit_testing)

# } unit testing, x86

####################################################################################################
# x86, stm32 {

function(add_target_config_args)
  add_target_config(
    ${PROJECT_NAME}
    SRC_DIR ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}
    BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY}
    TOOLCHAIN_FILE ${TOOLCHAIN_FILE}
    CMAKE_ARGUMENTS
      -DPROJECT_NAME=${PROJECT_NAME}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DMAIN_SOURCE_DIR=${PROJECT_SOURCE_DIR}
      -DBOARD_FAMILY=${BOARD_FAMILY}
      -DOUTPUT_PATH=${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
      ${ARGN}
  )
endfunction()

string(COMPARE EQUAL "${BOARD_FAMILY}" stm32 _cmp)
if (_cmp)

  set(TOOLCHAIN_FILE $ENV{STM32CMAKE_HOME}/cmake/gcc_stm32.cmake)
  set(STM32_CHIP $ENV{STM32_CHIP})
  set(STM32_FLASH_SIZE $ENV{STM32_FLASH_SIZE})
  set(STM32_RAM_SIZE $ENV{STM32_RAM_SIZE})
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})

  add_target_config_args(
    -DTOOLCHAIN_PREFIX=/usr/local
    -DSTM32_CHIP=${STM32_CHIP}
    -DSTM32_LINKER_SCRIPT=${STM32_CHIP}.ld
    -DSTM32_FLASH_SIZE=${STM32_FLASH_SIZE}
    -DSTM32_RAM_SIZE=${STM32_RAM_SIZE})
  add_target_build(${BIN_DIR} ${PROJECT_NAME})
  add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH} ${BOARD_FAMILY}
    ADDR 0x08000000 FLASH_SIZE ${STM32_FLASH_SIZE})

else ()

  string(COMPARE EQUAL "${BOARD_FAMILY}" avr _cmp)
  if (_cmp)

    set(TOOLCHAIN_FILE $ENV{ARDUINOCMAKE_HOME}/cmake/ArduinoToolchain.cmake)
    set(BOARD $ENV{BOARD})
    set(BOARD_CPU $ENV{BOARD_CPU})
    set(BOARD_PORT $ENV{BOARD_PORT})
    set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})

    add_target_config_args(-DBOARD=${BOARD} -DBOARD_CPU=${BOARD_CPU} -DBOARD_PORT=${BOARD_PORT})
    add_target_build(${BIN_DIR} ${PROJECT_NAME})
    add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH} ${BOARD_FAMILY})

  else()

    string(COMPARE EQUAL "${BOARD_FAMILY}" x86 _cmp)
    if (_cmp)
      add_subdirectory(${PROJECT_SOURCE_DIR}/src/x86)
    endif ()

  endif ()
endif ()
