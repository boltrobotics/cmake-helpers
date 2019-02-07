if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

include(init)

####################################################################################################
# AVR project {

if (PRINT_BOARDS)
  print_board_list()
endif ()

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

list(LENGTH SOURCES SOURCES_LEN)

if (SOURCES_LEN GREATER 0)
  if (BUILD_LIB AND BUILD_EXE)
    message(FATAL_ERROR "Both BUILD_LIB and BUILD_EXE are ON. Use one or the other")
  endif ()

  add_compile_options(-Wall -Wextra)
  add_definitions(-D${BOARD_FAMILY})

  if (NOT EXISTS ${MAIN_SRC})
    set(MAIN_SRC "")
  else ()
    list(REMOVE_ITEM SOURCES ${MAIN_SRC})
  endif ()

  if (ENABLE_USB_CON)
    add_definitions(-DUSB_CON)
  endif ()

  ##############################################################################
  # Build library
  message(STATUS "BUILD_LIB: ${BUILD_LIB}")
  if (BUILD_LIB)
    list(LENGTH SOURCES SOURCES_LEN)

    if (SOURCES_LEN GREATER 0)
      set(ignore_warning "${BOARD_PORT}")

      generate_arduino_library(
        ${PROJECT_NAME}${LIB_SUFFIX}
        BOARD ${BOARD}
        BOARD_CPU ${BOARD_CPU}
        SRCS ${SOURCES}
        LIBS ${LIB_LIBRARIES}
      )
    else ()
      message(STATUS "Cannot build ${PROJECT_NAME}${LIB_SUFFIX} without sources")
    endif ()
  endif ()

  ##############################################################################
  # Build executable
  message(STATUS "BUILD_EXE: ${BUILD_EXE}")
  if (BUILD_EXE)
    generate_arduino_firmware(
      ${PROJECT_NAME}${EXE_SUFFIX}
      BOARD ${BOARD}
      BOARD_CPU ${BOARD_CPU}
      PORT ${BOARD_PORT}
      SRCS ${MAIN_SRC} ${SOURCES}
      LIBS ${EXE_LIBRARIES}
      AFLAGS -v
    )
  endif ()

else ()
  message(STATUS "Project ${PROJECT_NAME} has no sources to build")
endif ()

# } AVR project
