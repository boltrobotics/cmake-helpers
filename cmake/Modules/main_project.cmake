include(init)
include(firmware)
include(unit_testing)

####################################################################################################
# stm32, avr, ard, x86 {

function(add_target_config_args)
  if (ENABLE_EXAMPLE)
    set(ENABLE_EXAMPLE_D "-DENABLE_EXAMPLE=ON")
  endif ()
  if (CMAKE_VERBOSE_MAKEFILE)
    set(CMAKE_VERBOSE_MAKEFILE_D "-DCMAKE_VERBOSE_MAKEFILE=ON")
  endif()

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
      ${ENABLE_EXAMPLE_D}
      ${CMAKE_VERBOSE_MAKEFILE_D}
      ${ARGN}
  )
endfunction()

if (NOT IS_DIRECTORY "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")
  message(STATUS "No sources to build for ${BOARD_FAMILY}")
  return()
endif ()

if (BTR_STM32 GREATER 0)

  set(TOOLCHAIN_PREFIX $ENV{ARMTOOLS_HOME})
  set(TOOLCHAIN_FILE $ENV{STM32CMAKE_HOME}/cmake/gcc_stm32.cmake)
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})
  set(STM32_CHIP $ENV{STM32_CHIP})
  set(STM32_FLASH_SIZE $ENV{STM32_FLASH_SIZE})
  set(STM32_RAM_SIZE $ENV{STM32_RAM_SIZE})

  include(stm32_project)
  setup_stm32()

  add_target_config_args(-DBTR_STM32=${BTR_STM32} -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX})
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
  if (BTR_ARD_NON_OBSOLETE)
    set(TOOLCHAIN_FILE $ENV{ARDUINOCMAKE_HOME}/cmake/ArduinoToolchain.cmake)
    set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})

    add_target_config_args(-DBTR_ARD=${BTR_ARD})
    add_target_build(${BIN_DIR} ${PROJECT_NAME})
    add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH})
  else ()
    message(STATUS "${Yellow}Arduino build is obsolete${ColourReset}")
  endif ()

elseif (BTR_X86 GREATER 0)

  add_subdirectory("${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")

endif ()

# } stm32, avr, ard, x86

add_test_subdirectory()
