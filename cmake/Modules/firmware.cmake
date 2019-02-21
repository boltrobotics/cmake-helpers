cmake_minimum_required(VERSION 3.5)

####################################################################################################
# config {

# Configure CMake project to build firmware.
#
function(add_target_config BIN_NAME)
  cmake_parse_arguments(p "" "SRC_DIR;BIN_DIR;TOOLCHAIN_FILE" "CMAKE_ARGUMENTS" ${ARGN})

  if (NOT p_SRC_DIR)
    message(SEND_ERROR "add_target_config called without SRC_DIR.")
  endif()

  if (NOT p_BIN_DIR)
    set(p_BIN_DIR ${PROJECT_BINARY_DIR}/${p_SRC_DIR})
    message(SEND_INFO "add_target_config called without BIN_DIR. Default: ${p_BIN_DIR}")
  endif()

  if (NOT p_TOOLCHAIN_FILE)
    message(SEND_ERROR "add_target_config called without TOOLCHAIN_FILE.")
  endif()

  set(DTOOLCHAIN_FILE -DCMAKE_TOOLCHAIN_FILE=${p_TOOLCHAIN_FILE})

  file(MAKE_DIRECTORY ${p_BIN_DIR})

  add_custom_target(
    ${BIN_NAME}-config
    WORKING_DIRECTORY ${p_BIN_DIR}
    COMMAND ${CMAKE_COMMAND} ${DTOOLCHAIN_FILE} ${p_CMAKE_ARGUMENTS} ${p_SRC_DIR}
  )
endfunction()

# } config

####################################################################################################
# build {

function(add_target_build BIN_DIR BIN_NAME)
  add_custom_target(
    ${BIN_NAME} ALL
    WORKING_DIRECTORY ${BIN_DIR}
    COMMAND ${CMAKE_COMMAND} --build ${BIN_DIR} -- ${BIN_NAME}
  )
  add_dependencies(${BIN_NAME} ${BIN_NAME}-config)
endfunction()

# } build

####################################################################################################
# flash {

function(add_target_flash BIN_DIR BIN_NAME OUT_DIR BOARD_FAMILY)

  if ((BOARD_FAMILY MATCHES avr) OR (BOARD_FAMILY MATCHES ard))

    add_custom_target(
      ${BIN_NAME}-flash
      WORKING_DIRECTORY ${BIN_DIR}
      COMMAND ${CMAKE_COMMAND} --build ${BIN_DIR} -- ${BIN_NAME}-upload
    )
    add_dependencies(${BIN_NAME}-flash ${BIN_NAME})

  elseif (BOARD_FAMILY MATCHES stm32)

    cmake_parse_arguments(p "" "ADDR;FLASH_SIZE" "" ${ARGN})

    if (p_FLASH_SIZE)
      set(FLASH_SIZE_PARAM "--flash=${p_FLASH_SIZE}")
    endif()

    if (NOT STFLASH)
      set(STFLASH st-flash)
      message(STATUS "No STFLASH specified, using default: ${STFLASH}")
    endif ()

    add_custom_target(
      ${BIN_NAME}-flash
      WORKING_DIRECTORY ${OUT_DIR}/bin
      COMMAND ${STFLASH} ${FLASH_SIZE_PARAM} write ${BIN_NAME}.bin ${p_ADDR}
    )
    add_dependencies(${BIN_NAME}-flash ${BIN_NAME})

  endif ()

endfunction()

# } flash
