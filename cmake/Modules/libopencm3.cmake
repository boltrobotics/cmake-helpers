include(project_setup)

set(LIBOPENCM3_HOME $ENV{LIBOPENCM3_HOME})
string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)

add_project(
  PREFIX libopencm3
  HOME "${LIBOPENCM3_HOME}"
  URL "https://github.com/libopencm3/libopencm3.git"
  BUILD_CMD "make TARGETS=stm32/${STM32_FAMILY_LOWER} VERBOSE=1"
  BUILD_IN 1
  FORCE_UPDATE 0
  LIB_DIR "${LIBOPENCM3_HOME}/lib"
  LIB_NAME opencm3_stm32${STM32_FAMILY_LOWER})

include_directories(${libopencm3_INC_DIR})
