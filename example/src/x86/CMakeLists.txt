include(x86_project)

set(CMAKE_MACOSX_RPATH 1)
find_package(Threads)

find_srcs(FILTER ${MAIN_SRC})
build_lib(SRCS "${SOURCES}" LIBS ${CMAKE_THREAD_LIBS_INIT} LIB_TYPE SHARED)
build_exe(OBJS "${SOURCES_OBJ}" SRCS "${MAIN_SRC}" LIBS ${PROJECT_NAME} SUFFIX "-exe")
