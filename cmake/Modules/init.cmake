if (NOT CMAKE_RULE_MESSAGES)
  message(STATUS "Setting default CMAKE_RULE_MESSAGES to OFF")
  set(CMAKE_RULE_MESSAGES OFF)
endif ()

if (NOT CMAKE_VERBOSE_MAKEFILE)
  message(STATUS "Setting default CMAKE_VERBOSE_MAKEFILE to ON")
  set(CMAKE_VERBOSE_MAKEFILE ON)
endif ()

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
  message(STATUS "Setting default CMAKE_BUILD_TYPE to ${CMAKE_BUILD_TYPE}")
endif ()

if (NOT OUTPUT_PATH)
  set(OUTPUT_PATH "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
endif ()

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

if (NOT ROOT_SOURCE_DIR)
  set(ROOT_SOURCE_DIR ${PROJECT_SOURCE_DIR})
endif ()

message(STATUS "ROOT_SOURCE_DIR: ${ROOT_SOURCE_DIR}")

set(MAIN_SRC ${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/main.cpp)

####################################################################################################
# Cross-compilation {

set(BOARD_FAMILY $ENV{BOARD_FAMILY})

if (NOT BOARD_FAMILY)
  message(STATUS "Setting default BOARD_FAMILY to x86 (options: x86 | stm32 | avr)")
  set(BOARD_FAMILY "x86")
endif()

if (NOT LIB_TYPE)
  set(LIB_TYPE SHARED)
endif ()

# } Cross-compilation

####################################################################################################
# Find sources recursively {

function (find_srcs)
  cmake_parse_arguments(p "" "" "FILTER" ${ARGN})

  file(GLOB_RECURSE SOURCES_SCAN
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c"
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.cpp"
    "${ROOT_SOURCE_DIR}/src/common/*.c"
    "${ROOT_SOURCE_DIR}/src/common/*.cpp")

  list(LENGTH p_FILTER FILTER_LEN)

  if (FILTER_LEN GREATER 0)
    message(STATUS  "Exclude sources: ${p_FILTER}")
    list(REMOVE_ITEM SOURCES_SCAN ${p_FILTER})
  endif ()

  set(SOURCES ${SOURCES_SCAN} PARENT_SCOPE)
endfunction ()

function (find_test_srcs)
  cmake_parse_arguments(p "" "" "FILTER" ${ARGN})

  file(GLOB_RECURSE SOURCES_SCAN
    "${ROOT_SOURCE_DIR}/test/*.c"
    "${ROOT_SOURCE_DIR}/test/*.cpp")

  list(LENGTH p_FILTER FILTER_LEN)

  if (FILTER_LEN GREATER 0)
    message(STATUS  "Exclude test sources: ${p_FILTER}")
    list(REMOVE_ITEM SOURCES_SCAN ${p_FILTER})
  endif ()

  set(SOURCES ${SOURCES_SCAN} PARENT_SCOPE)
endfunction ()

# } Find sources recursively
