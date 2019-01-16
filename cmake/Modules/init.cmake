if (NOT CMAKE_RULE_MESSAGES)
  message(STATUS "Setting default CMAKE_RULE_MESSAGES to OFF")
  set(CMAKE_RULE_MESSAGES OFF)
endif ()

if (NOT CMAKE_VERBOSE_MAKEFILE)
  message(STATUS "Setting default CMAKE_VERBOSE_MAKEFILE to ON")
  set(CMAKE_VERBOSE_MAKEFILE ON)
endif ()

if (NOT CMAKE_BUILD_TYPE)
  message(STATUS "Setting default CMAKE_BUILD_TYPE to Debug")
  set(CMAKE_BUILD_TYPE "Debug")
endif ()

set(OUTPUT_PATH "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
set(EXECUTABLE_OUTPUT_PATH "${OUTPUT_PATH}/bin")
set(LIBRARY_OUTPUT_PATH "${OUTPUT_PATH}/lib")

set(CMAKE_CXX_STANDARD 14)

function(print_variables)
  get_cmake_property(_VAR_NAMES VARIABLES)

  list (SORT _VAR_NAMES)
  foreach (_VAR_NAME ${_VAR_NAMES})
    message(STATUS "+++ ${_VAR_NAME}=${${_VAR_NAME}}")
  endforeach()
endfunction()

####################################################################################################
# Cross-compilation {

set(BOARD_FAMILY $ENV{BOARD_FAMILY})

if (NOT BOARD_FAMILY)
  message(STATUS "Setting default BOARD_FAMILY to x86 (options: x86 | stm32 | avr)")
  set(BOARD_FAMILY "x86")
endif()

# }
