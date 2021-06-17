include(x86_project)

find_package(Threads)

set(LIB_TYPE SHARED)
find_srcs(FILTER ${MAIN_SRC})

build_lib(SRCS "${SOURCES}" LIBS ${CMAKE_THREAD_LIBS_INIT} )
build_exe(OBJS "${SOURCES_OBJ}" SRCS "${MAIN_SRC}" LIBS ${PROJECT_NAME} SUFFIX "-exe")

set(DOXYGEN_WARN NO)
build_doc(DEP ${PROJECT_NAME}-exe SUFFIX "-docs")
