#include(init)

####################################################################################################
# Standard set-up {

add_definitions(-DBTR_X86=${BTR_X86})

if (CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Werror)
endif()

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  cmake_parse_arguments(
    p "" "TARGET;SUFFIX;LINK_LIBS_VISI;INC_DIR_VISI" "OBJS;SRCS;LIBS;INC_DIRS;DEPS;PIC" ${ARGN})

  if (p_TARGET)
    set(TARGET ${p_TARGET})
  else ()
    set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  endif ()
  if (NOT p_LINK_LIBS_VISI)
    set(p_LINK_LIBS_VISI PRIVATE)
  endif ()
  if (NOT p_INC_DIR_VISI)
    set(p_INC_DIR_VISI PRIVATE)
  endif ()

  list(LENGTH p_OBJS OBJS_LEN)
  list(LENGTH p_SRCS SRCS_LEN)
  list(LENGTH p_DEPS DEPS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    # Build object files
    add_library(${TARGET}_o OBJECT ${p_SRCS})

    set(SOURCES_OBJ ${TARGET}_o PARENT_SCOPE)

    if (NOT p_PIC)
      set(p_PIC OFF)
    endif ()

    set_property(TARGET ${TARGET}_o PROPERTY POSITION_INDEPENDENT_CODE ${p_PIC})

    if (OBJS_LEN GREATER 0)
      add_library(${TARGET} $<TARGET_OBJECTS:${TARGET}_o> $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_library(${TARGET} $<TARGET_OBJECTS:${TARGET}_o>)
    endif ()

    target_link_libraries(${TARGET} ${p_LINK_LIBS_VISI} ${p_LIBS})

    target_include_directories(${TARGET}_o ${p_INC_DIR_VISI} 
      "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
      "${ROOT_SOURCE_DIR}/src/common"
      "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
      "${ROOT_SOURCE_DIR}/include"
      "${p_INC_DIRS}"
    )

  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  if (DEPS_LEN GREATER 0)
    add_dependencies(${TARGET}_o ${p_DEPS})
  endif ()

endfunction ()

# } Build library

####################################################################################################
# Build executable {

function (build_exe)
  cmake_parse_arguments(
    p "" "TARGET;SUFFIX;LINK_LIBS_VISI;INC_DIR_VISI" "OBJS;SRCS;LIBS;INC_DIRS;DEPS;PIC;TEST" ${ARGN})

  if (p_TARGET)
    set(TARGET ${p_TARGET})
  else ()
    set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  endif ()
  if (NOT p_LINK_LIBS_VISI)
    set(p_LINK_LIBS_VISI PRIVATE)
  endif ()
  if (NOT p_INC_DIR_VISI)
    set(p_INC_DIR_VISI PRIVATE)
  endif ()

  list(LENGTH p_SRCS SRCS_LEN)
  list(LENGTH p_OBJS OBJS_LEN)
  list(LENGTH p_DEPS DEPS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    if (OBJS_LEN GREATER 0)
      add_executable(${TARGET} ${p_SRCS} $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_executable(${TARGET} ${p_SRCS})
    endif ()

    if (NOT p_PIC)
      set_property(TARGET ${TARGET} PROPERTY POSITION_INDEPENDENT_CODE OFF)
    else ()
      set_property(TARGET ${TARGET} PROPERTY POSITION_INDEPENDENT_CODE ON)
    endif ()

    set_property(TARGET ${TARGET} PROPERTY install_rpath "@loader_path/../lib")

    if (p_TEST)
      include(gtest)
      find_package(Threads REQUIRED)
      set(TEST_DEPS ${gtest_LIB_NAME} ${CMAKE_THREAD_LIBS_INIT})
      add_test(NAME ${TARGET} COMMAND $<TARGET_FILE:${TARGET}>)
    endif ()

    target_link_libraries(${TARGET} ${p_LINK_LIBS_VISI} ${p_LIBS} ${TEST_DEPS})

    target_include_directories(${TARGET} ${p_INC_DIR_VISI}
      "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
      "${ROOT_SOURCE_DIR}/src/common"
      "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
      "${ROOT_SOURCE_DIR}/include"
      "${p_INC_DIRS}"
    )

  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  if (DEPS_LEN GREATER 0)
    add_dependencies(${TARGET} ${p_DEPS})
  endif ()

endfunction ()

# } Build executable 
