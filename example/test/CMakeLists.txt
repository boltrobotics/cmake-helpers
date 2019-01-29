include(gtest)
include(project_setup)

####################################################################################################
# boost {

find_package(Boost REQUIRED COMPONENTS program_options system)
include_directories(${Boost_INCLUDE_DIRS})

# } boost

####################################################################################################

add_definitions(-D${BOARD_FAMILY})

include_directories(
  ${PROJECT_SOURCE_DIR}/src/${BOARD_FAMILY}
  ${PROJECT_SOURCE_DIR}/src/common
  ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}
  ${PROJECT_SOURCE_DIR}/include
  ${gtest_INC_DIR}
)

####################################################################################################
# unit tests {

file(GLOB SOURCES "*.cpp")

add_compile_options(-Wall -Wextra -Werror)

add_executable(${PROJECT_NAME}_tests ${SOURCES})
set_property(TARGET ${PROJECT_NAME}_tests PROPERTY install_rpath "@loader_path/../lib")
target_link_libraries(${PROJECT_NAME}_tests ${PROJECT_NAME} ${EXAMPLE_NAME} ${gtest_LIB_NAME})

add_test(NAME ${PROJECT_NAME}_tests COMMAND $<TARGET_FILE:${PROJECT_NAME}_tests>)

# } unit tests
