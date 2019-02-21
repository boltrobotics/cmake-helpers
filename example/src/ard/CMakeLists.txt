cmake_minimum_required(VERSION 3.5)
set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)

include(arduino_project)

find_srcs()
build_exe(SRCS ${SOURCES})
