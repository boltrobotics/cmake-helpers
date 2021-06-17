include(init)

####################################################################################################
# Standard set up {

add_definitions(-DBTR_X86=${BTR_X86})

if (CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Werror)
endif()

function (setup_x86)
endfunction ()

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  cmake_parse_arguments(p "" "SUFFIX" "OBJS;INC_DIRS;SRCS;LIBS;DEPS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_OBJS OBJS_LEN)
  list(LENGTH p_SRCS SRCS_LEN)
  list(LENGTH p_DEPS DEPS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    # Build object files
    add_library(${TARGET}_o OBJECT ${p_SRCS})

    if (LIB_TYPE MATCHES SHARED) 
      set_property(TARGET ${TARGET}_o PROPERTY POSITION_INDEPENDENT_CODE ON)
    endif ()

    set(SOURCES_OBJ ${TARGET}_o PARENT_SCOPE)

    if (OBJS_LEN GREATER 0)
      add_library(${TARGET} ${p_LIB_TYPE} $<TARGET_OBJECTS:${TARGET}_o> $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_library(${TARGET} ${p_LIB_TYPE} $<TARGET_OBJECTS:${TARGET}_o>)
    endif ()

    target_include_directories(${TARGET}_o PRIVATE
      "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
      "${ROOT_SOURCE_DIR}/src/common"
      "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
      "${ROOT_SOURCE_DIR}/include"
      "${p_INC_DIRS}"
    )

    target_link_libraries(${TARGET} PRIVATE ${p_LIBS})

  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  if (DEPS_LEN GREATER 0)
    add_dependencies(${TARGET} ${p_DEPS})
  endif ()

endfunction ()

# } Build library

####################################################################################################
# Build executable {

function (build_exe)
  cmake_parse_arguments(p "" "SUFFIX" "OBJS;INC_DIRS;SRCS;LIBS;DEPS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
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

    target_include_directories(${TARGET} PRIVATE
      "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
      "${ROOT_SOURCE_DIR}/src/common"
      "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
      "${ROOT_SOURCE_DIR}/include"
      "${p_INC_DIRS}"
    )

    target_link_libraries(${TARGET} ${p_LIBS})

  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  if (DEPS_LEN GREATER 0)
    add_dependencies(${TARGET} ${p_DEPS})
  endif ()

endfunction ()

# } Build executable 
