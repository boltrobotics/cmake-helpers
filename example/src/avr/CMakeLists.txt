cmake_minimum_required(VERSION 3.5)
project(${PROJECT_NAME})

set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
include(init)

####################################################################################################
# Firmware {

include_directories(
  ${MAIN_SOURCE_DIR}/src/${BOARD_FAMILY}
  ${MAIN_SOURCE_DIR}/src/common
  ${MAIN_SOURCE_DIR}/include
)

file(GLOB_RECURSE COMMON_SRC "${MAIN_SOURCE_DIR}/src/common/*.c*")
file(GLOB_RECURSE BOARD_SRC "${MAIN_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c*")
list(APPEND SOURCES ${COMMON_SRC} ${BOARD_SRC})

#print_board_list()

# Remove this if using an Arduino without native USB (eg, other than Leonardo)
#add_definitions(-DUSB_CON)
add_definitions(-D${BOARD_FAMILY})
add_compile_options(-Wall -Wextra)

generate_arduino_firmware(
	${PROJECT_NAME}
  BOARD ${BOARD}
  BOARD_CPU ${BOARD_CPU}
  PORT ${BOARD_PORT}
  SRCS ${SOURCES}
  AFLAGS -v
  #LIBS devices
)

# } Firmware
