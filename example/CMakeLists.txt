cmake_minimum_required(VERSION 3.7)
project(example)

set(CMAKE_MODULE_PATH $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
set(ROOT_SOURCE_DIR ${PROJECT_SOURCE_DIR})
include(main_project)
