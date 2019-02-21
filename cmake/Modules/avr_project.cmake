if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

include(init)

####################################################################################################
# Arduino boards {
# See: /Applications/Arduino.app/Contents/Java/hardware/arduino/avr/boards.txt

function(setup_mega)
  set(MCU_SPEED "16000000UL" PARENT_SCOPE)
  set(AVR_MCU atmega2560 PARENT_SCOPE)
  set(AVR_L_FUSE 0xFF PARENT_SCOPE)
  set(AVR_H_FUSE 0xD8 PARENT_SCOPE)
  set(AVR_E_FUSE 0xFD PARENT_SCOPE)
endfunction()

function(setup_uno)
  set(MCU_SPEED "16000000UL" PARENT_SCOPE)
  set(AVR_MCU atmega328p PARENT_SCOPE)
  set(AVR_L_FUSE 0xFF PARENT_SCOPE)
  set(AVR_H_FUSE 0xDA PARENT_SCOPE)
  set(AVR_E_FUSE 0xFD PARENT_SCOPE)
endfunction()

function(setup_due)
  set(MCU_SPEED "16000000UL" PARENT_SCOPE)
  set(AVR_MCU atmega168 PARENT_SCOPE)
  set(AVR_L_FUSE 0xFF PARENT_SCOPE)
  set(AVR_H_FUSE 0xDA PARENT_SCOPE)
  set(AVR_E_FUSE 0xFD PARENT_SCOPE)
endfunction()

# } Arduino boards

####################################################################################################
# Standard set up {

function (setup)
  if (DEFINED ENV{AVRTOOLS_ROOT})
    set(CMAKE_FIND_ROOT_PATH $ENV{AVRTOOLS_ROOT} PARENT_SCOPE)
  else ()
    message(FATAL_ERROR "AVRTOOLS_ROOT undefined")
  endif ()

  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY PARENT_SCOPE)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY PARENT_SCOPE)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER PARENT_SCOPE)

  include_directories(
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
    "${ROOT_SOURCE_DIR}/src/common"
    "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
    "${ROOT_SOURCE_DIR}/include"
  )

  if (CMAKE_BUILD_TYPE MATCHES Release)
    set(CMAKE_C_FLAGS_RELEASE "-Os" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS_RELEASE "-Os" PARENT_SCOPE)
  endif ()

  if (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Os -save-temps -g -gdwarf-3 -gstrict-dwarf" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-Os -save-temps -g -gdwarf-3 -gstrict-dwarf" PARENT_SCOPE)
  endif ()

  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(CMAKE_C_FLAGS_DEBUG "-O0 -save-temps -g -gdwarf-3 -gstrict-dwarf" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS_DEBUG "-O0 -save-temps -g -gdwarf-3 -gstrict-dwarf" PARENT_SCOPE)
  endif ()

  add_definitions(-D${BOARD_FAMILY} -DF_CPU=${MCU_SPEED})
  add_compile_options(-Wall -Wextra -pedantic -pedantic-errors)
  add_compile_options(-fpack-struct -fshort-enums -funsigned-char -funsigned-bitfields)
  add_compile_options(-ffunction-sections)

endfunction()

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  setup_gcc_avr_defaults()
  cmake_parse_arguments(p "" "SUFFIX" "SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_SRCS SRCS_LEN)

  if (SRCS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")
    add_avr_library(${TARGET} ${p_SRCS})

    if (p_LIBS)
      avr_target_link_libraries(${TARGET} ${p_LIBS})
    endif ()
  else ()
    message(STATUS "No sources to build: ${TARGET}")
  endif ()

endfunction ()

####################################################################################################
# Build executable {

function (build_exe)
  setup_gcc_avr_defaults()
  cmake_parse_arguments(p "" "SUFFIX" "SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${EXE_SUFFIX})
  list(LENGTH p_SRCS SRCS_LEN)

  if (SRCS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")
    add_avr_executable(${TARGET} ${p_SRCS})

    if (p_LIBS)
      avr_target_link_libraries(${TARGET} ${p_LIBS})
    endif ()
  else ()
    message(STATUS "No sources to build: ${TARGET}")
  endif ()

endfunction ()

# } Build executable 
