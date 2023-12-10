cmake_minimum_required(VERSION 3.16)
project(example)

include(avr_project)
setup_avr()
find_srcs()
build_exe(SRCS ${SOURCES})
