option(ENABLE_TESTS "Build unit tests" ON)

if (BTR_X86 GREATER 0 AND ENABLE_TESTS)
  enable_testing()
endif()

function(add_test_subdirectory)
  if (BTR_X86 GREATER 0)
    message(STATUS "ENABLE_TESTS: ${ENABLE_TESTS}")

    if (ENABLE_TESTS)
      if (EXISTS "${ROOT_SOURCE_DIR}/test")
        add_subdirectory(${ROOT_SOURCE_DIR}/test)
      else ()
        message(STATUS "Test directory doesn't exist: ${ROOT_SOURCE_DIR}/test")
      endif ()
    endif ()
  endif()
endfunction()
