cmake_minimum_required(VERSION 3.16)
project(example)

set(AVR_MCU atmega168)
set(AVR_UPLOADTOOL_PORT "/dev/tty.usbmodemFD14511")

include(avr_project)
setup_avr()
find_srcs()

####################################################################################################
# Build executable {

build_exe(SRCS ${SOURCES})

# } Build executable
