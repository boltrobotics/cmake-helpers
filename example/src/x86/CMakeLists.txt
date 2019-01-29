set(CMAKE_MACOSX_RPATH 1)
include(project_setup)

####################################################################################################
# ${PROJECT_NAME} {

find_package(Threads)

include_directories(
  ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}
  ${PROJECT_SOURCE_DIR}/src/common
  ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}
  ${PROJECT_SOURCE_DIR}/include
  )

file(GLOB_RECURSE COMMON_SRC "${PROJECT_SOURCE_DIR}/src/common/*.c*")
file(GLOB_RECURSE BOARD_SRC  "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c*")
list(APPEND SOURCES ${COMMON_SRC} ${BOARD_SRC})

set(MAIN_SRC ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}/main.cpp)
list(REMOVE_ITEM SOURCES ${MAIN_SRC})

add_definitions(-D${BOARD_FAMILY})
add_compile_options(-Wall -Wextra -Werror)

#add_library(${PROJECT_NAME}_o OBJECT ${SOURCES})
#set_property(TARGET ${PROJECT_NAME}_o PROPERTY POSITION_INDEPENDENT_CODE ON)

add_library(${PROJECT_NAME} SHARED ${SOURCES})
target_link_libraries(${PROJECT_NAME} PRIVATE ${CMAKE_THREAD_LIBS_INIT})

add_executable(${PROJECT_NAME}_exe ${MAIN_SRC})
target_link_libraries(${PROJECT_NAME}_exe ${PROJECT_NAME})

# } ${PROJECT_NAME}
