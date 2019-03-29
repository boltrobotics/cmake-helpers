include(init)

if (PRINT_BOARDS)
  print_board_list()
endif ()

if (ENABLE_USB_CON)
  add_definitions(-DUSB_CON)
endif ()

####################################################################################################
# Standard set up {

function (setup_arduino)
  if (NOT BOARD)
    set(BOARD uno)
    set(BOARD ${BOARD} PARENT_SCOPE)
  endif ()

  include_directories(
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
    "${ROOT_SOURCE_DIR}/src/avr"
    "${ROOT_SOURCE_DIR}/src/common"
    "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
    "${ROOT_SOURCE_DIR}/include"
  )

  add_definitions(-DBTR_ARD=${BTR_ARD})
  add_compile_options(-Wall -Wextra)
endfunction()

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  cmake_parse_arguments(p "" "SUFFIX" "SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_SRCS SRCS_LEN)

  if (SRCS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")
    set(ignore_warning "${PORT}")

    generate_arduino_library(
      ${TARGET}
      BOARD ${BOARD}
      BOARD_CPU ${BOARD_CPU}
      SRCS ${p_SRCS}
      LIBS ${p_LIBS}
    )
  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

endfunction ()

####################################################################################################
# Build executable {

function (build_exe)
  cmake_parse_arguments(p "" "SUFFIX" "SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${EXE_SUFFIX})
  list(LENGTH p_SRCS SRCS_LEN)

  if (SRCS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    generate_arduino_firmware(
      ${TARGET}
      BOARD ${BOARD}
      BOARD_CPU ${BOARD_CPU}
      PORT ${PORT}
      SRCS ${p_SRCS}
      LIBS ${p_LIBS}
      AFLAGS -v
    )
  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

endfunction ()

# } Build executable 
