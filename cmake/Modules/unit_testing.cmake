option(ENABLE_TESTS "Build unit tests" OFF)

string(COMPARE EQUAL "${BOARD_FAMILY}" x86 _cmp)
if (_cmp)

  if (ENABLE_TESTS)
    enable_testing()
    add_subdirectory(${PROJECT_SOURCE_DIR}/test)
  endif()

else ()
  message(STATUS "Project ${PROJECT_NAME} doesn't support unit testing on ${BOARD_FAMILY}")
endif()
