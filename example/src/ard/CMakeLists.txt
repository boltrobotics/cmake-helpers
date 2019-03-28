cmake_minimum_required(VERSION 3.7)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)

include(arduino_project)

setup_arduino()
find_srcs()
build_exe(SRCS ${SOURCES})
