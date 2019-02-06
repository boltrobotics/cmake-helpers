if (NOT SUBPROJECT_NAME)
  message(STATUS "Setting default SUBPROJECT_NAME to ${PROJECT_NAME}")
  project(${PROJECT_NAME})
else ()
  project(${SUBPROJECT_NAME})
endif ()

include(init)

####################################################################################################
# Firmware {

include_directories(
  ${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}
  ${ROOT_SOURCE_DIR}/src/common
  ${ROOT_SOURCE_DIR}/include
)

file(GLOB_RECURSE SOURCES
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c"
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.cpp"
  "${ROOT_SOURCE_DIR}/src/common/*.c"
  "${ROOT_SOURCE_DIR}/src/common/*.cpp")

if (PRINT_BOARDS)
  print_board_list()
endif ()

list(LENGTH SOURCES SOURCES_LEN)

if (SOURCES_LEN GREATER 0)
  add_compile_options(-Wall -Wextra)
  add_definitions(-D${BOARD_FAMILY})

  if (ENABLE_USB_CON)
    add_definitions(-DUSB_CON)
  endif ()

  message(STATUS "BUILD_EXE: ${BUILD_EXE}")

  if (BUILD_EXE)
    generate_arduino_firmware(
      ${PROJECT_NAME}
      BOARD ${BOARD}
      BOARD_CPU ${BOARD_CPU}
      PORT ${BOARD_PORT}
      SRCS ${SOURCES}
      AFLAGS -v
    )
  else ()
    set(ignore_warning "${BOARD_PORT}")

    generate_arduino_library(
      ${PROJECT_NAME}
      BOARD ${BOARD}
      BOARD_CPU ${BOARD_CPU}
      SRCS ${SOURCES}
    )
  endif ()

else ()
  message(STATUS "${PROJECT_NAME} has no sources to build")
endif ()

# } Firmware
