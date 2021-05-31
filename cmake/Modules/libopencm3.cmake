include(project_setup)

if (NOT LIBOPENCM3_HOME)
  message(FATAL_ERROR "LIBOPENCM3_HOME undefined")
endif ()

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)

add_project(
  PREFIX libopencm3
  HOME "${LIBOPENCM3_HOME}"
  SRC_DIR "${LIBOPENCM3_HOME}"
  URL "https://github.com/libopencm3/libopencm3.git"
  BUILD_CMD "make TARGETS=stm32/${STM32_FAMILY_LOWER}"
  BUILD_IN 1
  FORCE_UPDATE $ENV{FORCE_UPDATE}
  LIB_DIR "${LIBOPENCM3_HOME}/lib"
  LIB_NAME opencm3_stm32${STM32_FAMILY_LOWER})

include_directories(${libopencm3_INC_DIR})
