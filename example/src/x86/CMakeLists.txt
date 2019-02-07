set(CMAKE_MACOSX_RPATH 1)

find_package(Threads)

set(BUILD_LIB ON)
set(BUILD_EXE ON)
set(EXE_SUFFIX "-exe")

set(LIB_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
set(EXE_LIBRARIES ${PROJECT_NAME})

include(x86_project)
