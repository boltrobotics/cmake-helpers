option(ENABLE_TESTS "Build unit tests" ON)

if (BTR_X86 GREATER 0 AND ENABLE_TESTS)
  enable_testing()
endif()

function(add_test_subdirectory)
  if (BTR_X86 GREATER 0 AND ENABLE_TESTS)
    add_subdirectory(${PROJECT_SOURCE_DIR}/test)
  endif()
endfunction()
