cmake_minimum_required(VERSION 3.16)
project(example)

if (NOT AVR_MCU)
  set(AVR_MCU atmega168)
endif ()
if (NOT AVR_UPLOADTOOL_PORT)
  set(AVR_UPLOADTOOL_PORT "/dev/ttyACM0")
endif ()

include(avr_project)
setup_avr()
find_srcs()
build_exe(SRCS ${SOURCES})
