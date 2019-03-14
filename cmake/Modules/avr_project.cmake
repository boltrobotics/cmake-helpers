if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

include(init)

####################################################################################################
# Standard set up {

# WARNING: Usually, AVR library's CMakeLists.txt should not specify MCU, MCU_SPEED and PORT. The
# variables should be defined by the executable that links in the library.

function (setup_avr)
  cmake_parse_arguments(p "" "MCU;MCU_SPEED;PORT" "" ${ARGN})

  if (NOT p_MCU)
    if (NOT AVR_MCU)
      set(AVR_MCU atmega328p)
      message(STATUS "${BoldYellow}AVR_MCU default: ${AVR_MCU}${ColourReset}")
    endif ()
  else ()
    set(AVR_MCU ${p_MCU})
  endif ()
  set(AVR_MCU ${AVR_MCU} PARENT_SCOPE)

  # See: $ENV{ARDUINOCOREAVR_HOME}/boards.txt
  if (p_MCU MATCHES atmega168)
    set(AVR_L_FUSE 0xFF)
    set(AVR_H_FUSE 0xDA)
    set(AVR_E_FUSE 0xFD)
  elseif (p_MCU MATCHES atmega328p)
    set(AVR_L_FUSE 0xE2)
    set(AVR_H_FUSE 0xD9)
    set(AVR_E_FUSE 0xFF)
  elseif (p_MCU MATCHES atmega1280)
    set(AVR_L_FUSE 0xFF)
    set(AVR_H_FUSE 0xDA)
    set(AVR_E_FUSE 0xFD)
  elseif (p_MCU MATCHES atmega2560)
    set(AVR_L_FUSE 0xFF)
    set(AVR_H_FUSE 0xD8)
    set(AVR_E_FUSE 0xFF)
  endif ()
  set(AVR_L_FUSE ${AVR_L_FUSE} PARENT_SCOPE)
  set(AVR_H_FUSE ${AVR_H_FUSE} PARENT_SCOPE)
  set(AVR_E_FUSE ${AVR_E_FUSE} PARENT_SCOPE)

  if (p_MCU_SPEED)
    set(MCU_SPEED ${p_MCU_SPEED})
  else ()
    set(MCU_SPEED "16000000UL")
    message(STATUS "${BoldYellow}MCU_SPEED default: ${MCU_SPEED}${ColourReset}")
  endif ()
  set(MCU_SPEED ${MCU_SPEED} PARENT_SCOPE)

  if (p_PORT)
    set(AVR_UPLOADTOOL_PORT ${p_PORT})
    set(AVR_UPLOADTOOL_PORT ${AVR_UPLOADTOOL_PORT} PARENT_SCOPE)
  endif ()

  if (DEFINED ENV{AVRTOOLS_ROOT})
    set(CMAKE_FIND_ROOT_PATH $ENV{AVRTOOLS_ROOT} PARENT_SCOPE)
  else ()
    message(FATAL_ERROR "AVRTOOLS_ROOT undefined")
  endif ()

  message(STATUS "AVR_MCU: ${AVR_MCU}")
  message(STATUS "MCU_SPEED: ${MCU_SPEED}")
  message(STATUS "FUSES (l:h:e): ${AVR_L_FUSE}:${AVR_H_FUSE}:${AVR_E_FUSE}")
  message(STATUS "PORT: ${AVR_UPLOADTOOL_PORT}")

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
    message(STATUS "${BoldYellow}No sources to build: ${TARGET}${ColourReset}")
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
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")
    add_avr_executable(${TARGET} ${p_SRCS})

    if (p_LIBS)
      avr_target_link_libraries(${TARGET} ${p_LIBS})
    endif ()
  else ()
    message(STATUS "${BoldYellow}No sources to build: ${TARGET}${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

  avr_generate_fixed_targets()
endfunction ()

# } Build executable 
