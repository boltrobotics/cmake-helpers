message(STATUS "Processing: main_project.cmake")
include(init)
include(firmware)

message(STATUS "PROJECT_NAME: ${PROJECT_NAME}")
message(STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME}")
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "ROOT_SOURCE_DIR: ${ROOT_SOURCE_DIR}")
message(STATUS "OUTPUT_PATH: ${OUTPUT_PATH}")

####################################################################################################
# stm32, avr, x86 {

function(add_target_config_args)
  if (ENABLE_EXAMPLE)
    set(ENABLE_EXAMPLE_D "-DENABLE_EXAMPLE=ON")
  endif ()
  if (CMAKE_VERBOSE_MAKEFILE)
    set(CMAKE_VERBOSE_MAKEFILE_D "-DCMAKE_VERBOSE_MAKEFILE=ON")
  endif()

  # BOARD_FAMILY is set up in init.cmake
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

if (BTR_STM32 GREATER 0)
  if (NOT IS_DIRECTORY "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")
    message(STATUS "No sources to build for ${BOARD_FAMILY}")
    return()
  endif ()

  set(TOOLCHAIN_PREFIX $ENV{ARMTOOLS_HOME})
  set(TOOLCHAIN_FILE $ENV{CMAKEHELPERS_HOME}/cmake/Modules/gcc_stm32_toolchain.cmake)
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})
  set(STM32_CHIP $ENV{STM32_CHIP})
  set(STM32_FLASH_SIZE $ENV{STM32_FLASH_SIZE})
  set(STM32_RAM_SIZE $ENV{STM32_RAM_SIZE})

  if (NOT STM32_CHIP)
    set(STM32_CHIP stm32f103c8t6)
  endif ()

  if (NOT STM32_LINKER_SCRIPT)
    set(STM32_LINKER_SCRIPT ${STM32_CHIP}.ld)
  endif ()

  if (NOT STM32_FLASH_SIZE)
    set(STM32_FLASH_SIZE 64K)
  endif ()

  if (NOT STM32_RAM_SIZE)
    set(STM32_RAM_SIZE 20K)
  endif ()

  include(stm32_project)

  # Args will be passed to a cmake instance that would use a different toolchain. Specify
  # all arguments including environment variables that the cmake would need.
  add_target_config_args(
    -DBTR_STM32=${BTR_STM32} -DTOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX}
    -DSTM32_CHIP=${STM32_CHIP} -DSTM32_LINKER_SCRIPT=${STM32_LINKER_SCRIPT}
    -DSTM32_FLASH_SIZE=${STM32_FLASH_SIZE} -DSTM32_RAM_SIZE=${STM32_RAM_SIZE}
    -DLIBOPENCM3_HOME=$ENV{LIBOPENCM3_HOME} -DFREERTOS_HOME=$ENV{FREERTOS_HOME})
  add_target_build(${BIN_DIR} ${PROJECT_NAME})
  add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH} ADDR 0x08000000
    FLASH_SIZE ${STM32_FLASH_SIZE})

elseif (BTR_AVR GREATER 0)
  if (NOT IS_DIRECTORY "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")
    message(STATUS "No sources to build for ${BOARD_FAMILY}")
    return()
  endif ()

  set(TOOLCHAIN_FILE $ENV{CMAKEHELPERS_HOME}/cmake/Modules/gcc_avr_toolchain.cmake)
  set(BIN_DIR ${PROJECT_BINARY_DIR}/src/${BOARD_FAMILY})

  add_target_config_args(-DBTR_AVR=${BTR_AVR})
  add_target_build(${BIN_DIR} ${PROJECT_NAME})
  add_target_flash(${BIN_DIR} ${PROJECT_NAME} ${OUTPUT_PATH})

else ()
  if (NOT IS_DIRECTORY "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")
    message(STATUS "No sources to build for ${BOARD_FAMILY}")
  else ()
    add_subdirectory("${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}")
  endif ()

  if (ENABLE_TESTS)
    if (EXISTS "${ROOT_SOURCE_DIR}/test")
      enable_testing()
      add_subdirectory(${ROOT_SOURCE_DIR}/test)
    else ()
      message(WARNING "Test directory doesn't exist: ${ROOT_SOURCE_DIR}/test")
    endif ()
  endif()

  include(doxygen)
endif ()

# } stm32, avr, x86
