if (NOT ENABLE_TESTS)
  set(ENABLE_TESTS ON)
endif()

if (ENABLE_TESTS)
  enable_testing()
  add_subdirectory(${PROJECT_SOURCE_DIR}/test)
endif()
