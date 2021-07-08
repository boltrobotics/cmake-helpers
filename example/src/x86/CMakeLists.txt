include(x86_project)

find_srcs(FILTER ${MAIN_SRC})

build_lib(SRCS "${SOURCES}" LIBS ${CMAKE_THREAD_LIBS_INIT} PIC ON)
build_exe(OBJS "${SOURCES_OBJ}" SRCS "${MAIN_SRC}" LIBS ${PROJECT_NAME} SUFFIX "-exe" PIC ON)

set(DOXYGEN_WARN NO)
build_doc(DEP ${PROJECT_NAME}-exe SUFFIX "-docs")
