if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

####################################################################################################
# Standard set up {

function (setup)
  include_directories(
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
    "${ROOT_SOURCE_DIR}/src/common"
    "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
    "${ROOT_SOURCE_DIR}/include"
  )

  add_definitions(-D${BOARD_FAMILY})
  add_compile_options(-Wall -Wextra -Werror)
endfunction()

# Call setup as a default step for now.
setup()

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  cmake_parse_arguments(p "" "SUFFIX;LIB_TYPE" "OBJS;SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_OBJS OBJS_LEN)
  list(LENGTH p_SRCS SRCS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    # Build object files
    add_library(${TARGET}_o OBJECT ${p_SRCS})

    if (p_LIB_TYPE) 
      string(COMPARE EQUAL ${p_LIB_TYPE} SHARED _cmp)
      if (_cmp)
        set_property(TARGET ${TARGET}_o PROPERTY POSITION_INDEPENDENT_CODE ON)
      endif ()
    endif ()

    set(SOURCES_OBJ ${TARGET}_o PARENT_SCOPE)

    if (OBJS_LEN GREATER 0)
      add_library(${TARGET} ${p_LIB_TYPE} $<TARGET_OBJECTS:${TARGET}_o> $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_library(${TARGET} ${p_LIB_TYPE} $<TARGET_OBJECTS:${TARGET}_o>)
    endif ()

    target_link_libraries(${TARGET} PRIVATE ${p_LIBS})

  else ()
    message(STATUS "No sources to build: ${TARGET}")
  endif ()

endfunction ()

# } Build library

####################################################################################################
# Build executable {

function (build_exe)
  cmake_parse_arguments(p "" "SUFFIX" "OBJS;SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_SRCS SRCS_LEN)
  list(LENGTH p_OBJS OBJS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    if (OBJS_LEN GREATER 0)
      add_executable(${TARGET} ${p_SRCS} $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_executable(${TARGET} ${p_SRCS})
    endif ()
    target_link_libraries(${TARGET} ${p_LIBS})
  else ()
    message(STATUS "No sources to build: ${TARGET}")
  endif ()

endfunction ()

# } Build executable 
