if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

####################################################################################################
# x86 project {

include_directories(
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
  "${ROOT_SOURCE_DIR}/src/common"
  "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
  "${ROOT_SOURCE_DIR}/include"
)

file(GLOB_RECURSE SOURCES_SCAN
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c"
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.cpp"
  "${ROOT_SOURCE_DIR}/src/common/*.c"
  "${ROOT_SOURCE_DIR}/src/common/*.cpp")
list(APPEND SOURCES ${SOURCES_SCAN})

if (REMOVE_SOURCES)
  message(STATUS "Removing sources from ${PROJECT_NAME}: ${REMOVE_SOURCES}")
  list(REMOVE_ITEM SOURCES ${REMOVE_SOURCES})
endif()

message(STATUS "${PROJECT_NAME} SOURCES: ${SOURCES}")

list(LENGTH SOURCES SOURCES_LEN)

if (SOURCES_LEN GREATER 0)

  add_definitions(-D${BOARD_FAMILY})
  add_compile_options(-Wall -Wextra -Werror)

  if (NOT EXISTS ${MAIN_SRC})
    set(MAIN_SRC "")
  else ()
    list(REMOVE_ITEM SOURCES ${MAIN_SRC})
  endif ()

  ##############################################################################
  # Build object files
  add_library(${PROJECT_NAME}_o OBJECT ${SOURCES})

  string(COMPARE EQUAL "${LIB_TYPE}" SHARED _cmp)
  if (_cmp)
    set_property(TARGET ${PROJECT_NAME}_o PROPERTY POSITION_INDEPENDENT_CODE ON)
  endif ()

  ##############################################################################
  # Build library
  message(STATUS "BUILD_LIB: ${BUILD_LIB}")
  if (BUILD_LIB)
    list(LENGTH SOURCES SOURCES_LEN)

    if (SOURCES_LEN GREATER 0)
      add_library(${PROJECT_NAME}${LIB_SUFFIX} ${LIB_TYPE} $<TARGET_OBJECTS:${PROJECT_NAME}_o>)
      target_link_libraries(${PROJECT_NAME}${LIB_SUFFIX} PRIVATE ${LIB_LIBRARIES})
    else ()
      message(STATUS "Cannot build ${PROJECT_NAME}${LIB_SUFFIX} without sources")
    endif ()
  endif ()

  ##############################################################################
  # Build executable
  message(STATUS "BUILD_EXE: ${BUILD_EXE}")
  if (BUILD_EXE)
    add_executable(${PROJECT_NAME}${EXE_SUFFIX} ${MAIN_SRC} $<TARGET_OBJECTS:${PROJECT_NAME}_o>)
    target_link_libraries(${PROJECT_NAME}${EXE_SUFFIX} ${EXE_LIBRARIES})
  endif ()

else ()
  message(STATUS "Project ${PROJECT_NAME} has no sources to build. Root: ${ROOT_SOURCE_DIR}")
endif ()

# } x86 project
