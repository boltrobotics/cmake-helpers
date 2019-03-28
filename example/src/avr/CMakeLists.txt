cmake_minimum_required(VERSION 3.7)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)

include(avr_project)

set(AVR_MCU atmega168)
set(AVR_UPLOADTOOL_PORT "/dev/tty.usbmodemFD14511")
setup_avr()

find_srcs()
build_exe(SRCS ${SOURCES})
