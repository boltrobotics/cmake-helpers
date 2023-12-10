message(STATUS "Processing: init.cmake")

if (NOT WIN32)
  string(ASCII 27 Esc)
  set(ColourReset "${Esc}[m")
  set(ColourBold  "${Esc}[1m")
  set(Red         "${Esc}[31m")
  set(Green       "${Esc}[32m")
  set(Yellow      "${Esc}[33m")
  set(Blue        "${Esc}[34m")
  set(Magenta     "${Esc}[35m")
  set(Cyan        "${Esc}[36m")
  set(White       "${Esc}[37m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldGreen   "${Esc}[1;32m")
  set(BoldYellow  "${Esc}[1;33m")
  set(BoldBlue    "${Esc}[1;34m")
  set(BoldMagenta "${Esc}[1;35m")
  set(BoldCyan    "${Esc}[1;36m")
  set(BoldWhite   "${Esc}[1;37m")
endif()

if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

if (NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 99)
endif ()

if (NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(CMAKE_MACOSX_RPATH 1)
endif()

if (BTR_STM32 GREATER 0)
  set(BOARD_FAMILY stm32)
elseif (BTR_AVR GREATER 0)
  set(BOARD_FAMILY avr)
else ()
  set(BOARD_FAMILY x86)
  set(BTR_X86 1)
endif ()

# set(CMAKE_RULE_MESSAGES OFF)
# set(CMAKE_VERBOSE_MAKEFILE ON)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif ()

if (NOT OUTPUT_PATH)
  set(OUTPUT_PATH "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
endif ()

if (NOT ROOT_SOURCE_DIR)
  set(ROOT_SOURCE_DIR ${PROJECT_SOURCE_DIR})
endif ()

set(EXECUTABLE_OUTPUT_PATH "${OUTPUT_PATH}/bin")
set(LIBRARY_OUTPUT_PATH "${OUTPUT_PATH}/lib")
set(MAIN_SRC ${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/main.cpp)

include(doxygen)

####################################################################################################
# Print all variables {

function(print_variables)
  get_cmake_property(_VAR_NAMES VARIABLES)

  list (SORT _VAR_NAMES)

  foreach (_VAR_NAME ${_VAR_NAMES})
    message(STATUS "+++ ${_VAR_NAME}=${${_VAR_NAME}}")
  endforeach()
endfunction()

# } Print all variables

####################################################################################################
# Find sources {

function (find_srcs)
  cmake_parse_arguments(p "" "" "FILTER;XTRA_PATHS" ${ARGN})

  file(GLOB_RECURSE SOURCES_SCAN
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c"
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.cpp"
    "${ROOT_SOURCE_DIR}/src/common/*.c"
    "${ROOT_SOURCE_DIR}/src/common/*.cpp"
    "${p_XTRA_PATHS}"
    )

  list(LENGTH p_FILTER FILTER_LEN)

  if (FILTER_LEN GREATER 0)
    message(STATUS  "Exclude sources: ${p_FILTER}")
    list(REMOVE_ITEM SOURCES_SCAN ${p_FILTER})
  endif ()

  set(SOURCES ${SOURCES_SCAN} PARENT_SCOPE)
endfunction ()

# } Find sources

####################################################################################################
# Find test sources {

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

# } Find test sources

####################################################################################################
# Set up dependency {

function (setup_dep NAME HOME)
  cmake_parse_arguments(p "" "INC_DIR;SUB_DIR;LIB_NAME" "" ${ARGN})

  if (p_INC_DIR)
    set(${NAME}_INC_DIR ${HOME}/${p_INC_DIR} PARENT_SCOPE)
  else ()
    set(${NAME}_INC_DIR ${HOME}/include PARENT_SCOPE)
  endif ()

  if (p_LIB_NAME)
    set(BTR_LIBS ${BTR_LIBS} ${p_LIB_NAME} PARENT_SCOPE)
  endif ()

  if (NOT TARGET ${NAME} AND p_SUB_DIR)
    set(ROOT_SOURCE_DIR ${HOME})
    set(SUBPROJECT_NAME ${NAME})
    add_subdirectory(${HOME}/${p_SUB_DIR} ${PROJECT_BINARY_DIR}/${NAME})
  endif ()
endfunction()

# } Set up dependency
