include(gtest)

####################################################################################################
# Standard set-up {

add_definitions(-DBTR_X86=1)

if (CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Werror)
endif()

# } Standard set-up

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
# Build executable {

function (build_tests)
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

    set_property(TARGET ${TARGET} PROPERTY install_rpath "@loader_path/../lib")
    target_link_libraries(${TARGET} ${p_LIBS} ${Boost_LIBRARIES} ${gtest_LIB_NAME})
    add_test(NAME ${TARGET} COMMAND $<TARGET_FILE:${TARGET}>)

  else ()
    message(STATUS "${BoldYellow}No sources to build: ${TARGET}${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  if (DEPS_LEN GREATER 0)
    add_dependencies(${TARGET} ${p_DEPS})
  endif ()

endfunction ()

# } Build executable 
