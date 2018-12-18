cmake_minimum_required(VERSION 3.5)

# Configure CMake project to build firmware.
#
function(add_target_config)
  cmake_parse_arguments(fm "" "DIRECTORY;TOOLCHAIN_FILE;BOARD_FAMILY" "CMAKE_ARGUMENTS" ${ARGN})

  if (NOT fm_DIRECTORY)
    message(SEND_ERROR "add_target_config called without DIRECTORY.")
  endif()

  if (NOT fm_TOOLCHAIN_FILE)
    message(SEND_ERROR "add_target_config called without TOOLCHAIN_FILE.")
  endif()

  if (NOT fm_BOARD_FAMILY)
    message(SEND_ERROR "add_target_config called without BOARD_FAMILY.")
  endif()

  # Create a build tree directory for configuring the client's CMake project.
  file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/${fm_DIRECTORY})

  set(DTOOLCHAIN_FILE -DCMAKE_TOOLCHAIN_FILE=${fm_TOOLCHAIN_FILE})

  add_custom_target(
    ${PROJECT_NAME}_${fm_BOARD_FAMILY}_config
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${fm_DIRECTORY}
    COMMAND ${CMAKE_COMMAND} ${DTOOLCHAIN_FILE} ${fm_CMAKE_ARGUMENTS}
        ${PROJECT_SOURCE_DIR}/${fm_DIRECTORY}
  )
endfunction()

####################################################################################################
# Add a target "build".
#
# :param dir: subdirectory of current package with subproject
# :type dir: string
# :param bf: board family
# :type bf: string
# :param ARGN: holds the list of arguments past the last expected argument and is to contain
#   firmware targets to build
# :type ARGN: string
#
function(add_target_build dir bf)
  add_custom_target(
    ${PROJECT_NAME}_${bf}_build ALL
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${dir}/${bf}
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR}/${dir}/${bf} -- ${PROJECT_NAME}_${bf}
  )
  add_dependencies(${PROJECT_NAME}_${bf}_build ${PROJECT_NAME}_${bf}_config)
endfunction()

####################################################################################################
#
macro(SET_STFLASH)
  if (NOT STFLASH)
    set(STFLASH st-flash)
    message(STATUS "No STFLASH specified, using default: ${STFLASH}")
  endif ()
endmacro()

####################################################################################################
#
function(add_target_flash dir bf addr)
  SET_STFLASH()

  add_custom_target(
    ${PROJECT_NAME}_${bf}_flash
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${dir}/${bf}
    COMMAND ${STFLASH} write ${EXECUTABLE_OUTPUT_PATH}/${PROJECT_NAME}_${bf}.bin ${addr}
  )
  add_dependencies(${PROJECT_NAME}_${bf}_flash ${PROJECT_NAME}_${bf}_build)
endfunction()

####################################################################################################
#
function(add_target_flash128 dir bf addr)
  SET_STFLASH()

  add_custom_target(
    ${PROJECT_NAME}_${bf}_flash128
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/${dir}/${bf}
    COMMAND ${STFLASH} --flash=128K write ${EXECUTABLE_OUTPUT_PATH}/${PROJECT_NAME}_${bf}.bin
      ${addr}
  )
  add_dependencies(${PROJECT_NAME}_${bf}_flash128 ${PROJECT_NAME}_${bf}_build)
endfunction()
