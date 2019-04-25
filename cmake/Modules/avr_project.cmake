include(init)

####################################################################################################
# Standard set up {

macro (setup_fuses LF HF EF)
  if (NOT AVR_L_FUSE)
    set(AVR_L_FUSE ${LF})
    set(AVR_L_FUSE ${AVR_L_FUSE} PARENT_SCOPE)
  endif ()
  if (NOT AVR_H_FUSE)
    set(AVR_H_FUSE ${HF})
    set(AVR_H_FUSE ${AVR_H_FUSE} PARENT_SCOPE)
  endif ()
  if (NOT AVR_E_FUSE)
    set(AVR_E_FUSE ${EF})
    set(AVR_E_FUSE ${AVR_E_FUSE} PARENT_SCOPE)
  endif ()
endmacro ()

# IMPORTANT: When building executable, CMakeLists.txt of an AVR library that the executable links
# in is not expected to specify AVR_MCU, MCU_SPEED and AVR_UPLOADTOOL_PORT. The variables should be
# defined by the executable. If only building a library, define those variables.
#
function (setup_avr)
  if (NOT AVR_MCU)
    set(AVR_MCU atmega328p)
  endif ()
  set(AVR_MCU ${AVR_MCU} PARENT_SCOPE)

  if (NOT MCU_SPEED)
    set(MCU_SPEED "16000000UL")
  endif ()
  set(MCU_SPEED ${MCU_SPEED} PARENT_SCOPE)

  if (NOT AVR_UPLOADTOOL_PORT)
    message(FATAL_ERROR "AVR_UPLOADTOOL_PORT undefined")
  endif ()

  if (NOT AVR_PROGRAMMER)
    set(AVR_PROGRAMMER wiring)
    set(AVR_PROGRAMMER ${AVR_PROGRAMMER} PARENT_SCOPE)
  endif ()

  if (DEFINED ENV{AVRTOOLS_HOME})
    set(CMAKE_FIND_ROOT_PATH $ENV{AVRTOOLS_HOME} PARENT_SCOPE)
  else ()
    message(FATAL_ERROR "AVRTOOLS_HOME undefined")
  endif ()

  # For fuse settings see: $ENV{ARDUINOCOREAVR_HOME}/boards.txt
  if (AVR_MCU MATCHES atmega168)
    setup_fuses(0xFF 0xDA 0xFD)
  elseif (AVR_MCU MATCHES atmega328p)
    setup_fuses(0xE2 0xD9 0xFF)
  elseif (AVR_MCU MATCHES atmega1280)
    setup_fuses(0xFF 0xDA 0xFD)
  elseif (AVR_MCU MATCHES atmega2560)
    setup_fuses(0xFF 0xD8 0xFF)
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

  add_definitions(-DBTR_AVR=${BTR_AVR})
  add_definitions(-DF_CPU=${MCU_SPEED})
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
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
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
    message(STATUS "AVR_MCU: ${AVR_MCU}")
    message(STATUS "AVR_UPLOADTOOL_PORT: ${AVR_UPLOADTOOL_PORT}")
    message(STATUS "AVR_L_FUSE: ${AVR_L_FUSE}")
    message(STATUS "AVR_H_FUSE: ${AVR_H_FUSE}")
    message(STATUS "AVR_E_FUSE: ${AVR_E_FUSE}")
    message(STATUS "MCU_SPEED: ${MCU_SPEED}")
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    add_avr_executable(${TARGET} ${p_SRCS})

    if (p_LIBS)
      avr_target_link_libraries(${TARGET} ${p_LIBS})
    endif ()
  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  avr_generate_fixed_targets()
endfunction ()

# } Build executable 
