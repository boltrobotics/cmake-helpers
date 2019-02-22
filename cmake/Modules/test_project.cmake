include(gtest)

####################################################################################################
# Standard set up {

function (setup)
  include_directories(
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
    "${ROOT_SOURCE_DIR}/src/common"
    "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
    "${ROOT_SOURCE_DIR}/include"
    "${gtest_INC_DIR}"
  )

  add_definitions(-DBTR_X86=${BTR_X86})
  add_compile_options(-Wall -Wextra -Werror)
endfunction()

# Call setup as a default step for now.
setup()

# } Standard setup

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

    set_property(TARGET ${TARGET} PROPERTY install_rpath "@loader_path/../lib")
    target_link_libraries(${TARGET} ${p_LIBS} ${Boost_LIBRARIES} ${gtest_LIB_NAME})
    add_test(NAME ${TARGET} COMMAND $<TARGET_FILE:${TARGET}>)

  else ()
    message(STATUS "No sources to build: ${TARGET}")
  endif ()

endfunction ()

# } Build executable 
