include(test_project)

find_test_srcs()
build_exe(SRCS ${SOURCES} LIBS ${PROJECT_NAME} SUFFIX "-tests")
