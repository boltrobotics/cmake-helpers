include(gtest)

####################################################################################################
# unit tests {

add_definitions(-D${BOARD_FAMILY})

include_directories(
  "${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}"
  "${PROJECT_SOURCE_DIR}/src/common"
  "${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}"
  "${PROJECT_SOURCE_DIR}/include"
  "${gtest_INC_DIR}"
)

file(GLOB_RECURSE SOURCES_SCAN
  "${PROJECT_SOURCE_DIR}/test/*.c"
  "${PROJECT_SOURCE_DIR}/test/*.cpp")
list(APPEND SOURCES ${SOURCES_SCAN})

if (REMOVE_SOURCES)
  message(STATUS "Removing sources from ${PROJECT_NAME}: ${REMOVE_SOURCES}")
  list(REMOVE_ITEM SOURCES ${REMOVE_SOURCES})
endif()

add_compile_options(-Wall -Wextra -Werror)

add_executable(${PROJECT_NAME}${EXE_SUFFIX} ${SOURCES})
set_property(TARGET ${PROJECT_NAME}${EXE_SUFFIX} PROPERTY install_rpath "@loader_path/../lib")
target_link_libraries(${PROJECT_NAME}${EXE_SUFFIX}
  ${EXE_LIBRARIES} ${gtest_LIB_NAME} ${Boost_LIBRARIES})

add_test(NAME ${PROJECT_NAME}${EXE_SUFFIX} COMMAND $<TARGET_FILE:${PROJECT_NAME}${EXE_SUFFIX}>)

# } unit tests
