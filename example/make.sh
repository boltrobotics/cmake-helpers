#!/bin/bash

################################################################################
# Dependency paths

if [ -z ${PROJECTS_HOME} ]; then
  # Assume the script is invoked from within its project.
  export PROJECTS_HOME="${PWD}/../.."
fi
if [ -z ${XTRA_HOME} ]; then
  export XTRA_HOME=${PROJECTS_HOME}/other
fi

# Bolt Robotics projects

if [ -z ${CMAKEHELPERS_HOME} ]; then
  export CMAKEHELPERS_HOME=${PROJECTS_HOME}/cmake-helpers
fi

# Third-party projects

if [ -z ${GTEST_HOME} ]; then
  export GTEST_HOME=${XTRA_HOME}/gtest
fi
if [ -z ${FREERTOS_HOME} ]; then
  export FREERTOS_HOME=${XTRA_HOME}/freertos
fi
if [ -z ${LIBOPENCM3_HOME} ]; then
  export LIBOPENCM3_HOME=${XTRA_HOME}/libopencm3
fi

################################################################################
# Functions

function clone_impl()
{
  echo "Checking $(basename $2)"
  echo -e "  Source: $1"
  echo -e "  Target: $2"

  if [ -d ${2} ]; then
    (cd ${2} && git pull)
  else
    git clone $1 ${2}
  fi
}

function clone()
{
  clone_impl "https://github.com/google/googletest.git" "${GTEST_HOME}" 
  clone_impl "https://github.com/libopencm3/libopencm3.git" "${LIBOPENCM3_HOME}" 
  clone_impl "https://github.com/FreeRTOS/FreeRTOS-Kernel.git" "${FREERTOS_HOME}" 
}

# Process command-line options

x86=0; avr=0; stm32=0; esp32=0;
TESTS=""
VERBOSE=""
COMPILELOG=""

function build()
{
  (set -x && \
    cd ${CMAKEHELPERS_HOME}/example \
    && mkdir -p build-${1} && cd build-${1} \
    && cmake -G Ninja -DBTR_${1^^}=1${TESTS}${VERBOSE}${COMPILELOG}"${2}" .. \
    && cmake --build . \
  )
}

help()
{
  echo -e "Usage: `basename $0` [-x] [-a] [-s] [-e] [-d] [-c] [-v] [-t] [-h]"
  echo -e "  -x - build x86"
  echo -e "  -s - build stm32"
  echo -e "  -e - build esp32"
  echo -e "  -a - build avr"
  echo -e "  -d - clone or pull dependencies"
  echo -e "  -c - export compile commands"
  echo -e "  -v - enable verbose output"
  echo -e "  -t - enable unit tests"
  echo -e "  -h - this help"
}

while getopts "xasedcvth" Option
do
  case $Option in
    x) x86=1;;
    a) avr=1;;
    s) stm32=1;;
    e) esp32=1;;
    d) clone;;
    c) COMPILELOG=" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";;
    v) VERBOSE=" -DCMAKE_VERBOSE_MAKEFILE=ON";;
    t) TESTS=" -DENABLE_TESTS=ON";;
    h) help; exit 0;;
    \?) help; exit 22;;
  esac
done

shift $(($OPTIND - 1))

if [ ${x86} -eq 1 ]; then build x86 " $@"; fi
if [ ${avr} -eq 1 ]; then build avr " $@"; fi
if [ ${stm32} -eq 1 ]; then build stm32 " $@"; fi
if [ ${esp32} -eq 1 ]; then build esp32 " $@"; fi
