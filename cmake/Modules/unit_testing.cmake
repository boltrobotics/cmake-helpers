string(COMPARE EQUAL "${BOARD_FAMILY}" x86 _cmp)

if (_cmp)
  if (NOT ENABLE_TESTS)
    set(ENABLE_TESTS ON)
  endif()

  if (ENABLE_TESTS)
    enable_testing()
    add_subdirectory(${PROJECT_SOURCE_DIR}/test)
  endif()

else ()
  message(STATUS "${PROJECT_NAME} doesn't support unit testing for ${BOARD_FAMILY}")
endif()
