cmake_minimum_required(VERSION 3.7)

if (NOT PROJECT_NAME)
  message(WARNING "PROJECT_NAME undefined")
endif ()

project(${PROJECT_NAME})

include(init)
include(firmware)

####################################################################################################
# unit testing, x86 {

include(unit_testing)

# } unit testing, x86

####################################################################################################
# stm32, avr, ard, x86 {

function(add_target_config_args)
  add_target_config(
    ${PROJECT_NAME}
    SRC_DIR ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}
    BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY}
    TOOLCHAIN_FILE ${TOOLCHAIN_FILE}
    CMAKE_ARGUMENTS
      -DSUBPROJECT_NAME=${PROJECT_NAME}
      -DROOT_SOURCE_DIR=${ROOT_SOURCE_DIR}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DOUTPUT_PATH=${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
      -DBOARD_FAMILY=${BOARD_FAMILY}
      ${ARGN}
  )
endfunction()

if (NOT IS_DIRECTORY "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")
  message(STATUS "No sources to build for ${BOARD_FAMILY}")
  return()
endif ()

if (BTR_STM32 GREATER 0)

  set(TOOLCHAIN_FILE $ENV{STM32CMAKE_HOME}/cmake/gcc_stm32.cmake)
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})
  set(STM32_CHIP $ENV{STM32_CHIP})
  set(STM32_FLASH_SIZE $ENV{STM32_FLASH_SIZE})
  set(STM32_RAM_SIZE $ENV{STM32_RAM_SIZE})

  add_target_config_args(
    -DBTR_STM32=${BTR_STM32}
    -DTOOLCHAIN_PREFIX=/usr/local
    -DSTM32_CHIP=${STM32_CHIP}
    -DSTM32_LINKER_SCRIPT=${STM32_CHIP}.ld
    -DSTM32_FLASH_SIZE=${STM32_FLASH_SIZE}
    -DSTM32_RAM_SIZE=${STM32_RAM_SIZE})
  add_target_build(${BIN_DIR} ${PROJECT_NAME})
  add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH} ADDR 0x08000000
    FLASH_SIZE ${STM32_FLASH_SIZE})

elseif (BTR_AVR GREATER 0)

  set(TOOLCHAIN_FILE $ENV{CMAKEHELPERS_HOME}/cmake/Modules/generic-gcc-avr.cmake)
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})

  add_target_config_args(-DBTR_AVR=${BTR_AVR})
  add_target_build(${BIN_DIR} ${PROJECT_NAME})
  add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH})

elseif (BTR_ARD GREATER 0)

  set(TOOLCHAIN_FILE $ENV{ARDUINOCMAKE_HOME}/cmake/ArduinoToolchain.cmake)
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})
  set(BOARD $ENV{BOARD})
  set(BOARD_CPU $ENV{BOARD_CPU})
  set(BOARD_PORT $ENV{BOARD_PORT})
  set(PRINT_BOARDS $ENV{PRINT_BOARDS})

  add_target_config_args(
    -DBTR_ARD=${BTR_ARD}
    -DBOARD=${BOARD}
    -DBOARD_CPU=${BOARD_CPU}
    -DBOARD_PORT=${BOARD_PORT}
    -DPRINT_BOARDS=${PRINT_BOARDS})
  add_target_build(${BIN_DIR} ${PROJECT_NAME})
  add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH})

elseif (BTR_X86 GREATER 0)

  add_subdirectory("${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")

endif ()

# } stm32, avr, ard, x86
