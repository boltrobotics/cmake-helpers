#!/bin/bash

X86=0
STM32=0
ESP32=0
AVR=0
DEPS=0
TESTS=""

help()
{
  echo -e "Usage: `basename $0` [-x] [-s] [-e] [-a] [-d] [-t] [-p _projects_home_] [-h]"
  echo -e "  -x - build x86"
  echo -e "  -s - build stm32"
  echo -e "  -e - build esp32"
  echo -e "  -a - build avr"
  echo -e "  -d - pull dependencies"
  echo -e "  -t - enable unit tests"
  echo -e "  -p - absolute path to projects home"
  echo -e "  -h - this help"
}

# Clone repository in github or pull any changes.
function clone_or_pull {
  echo "Checking $(basename $1)"
  echo -e "  Source: $2"
  echo -e "  Target: $1"

  if [ -d ${1} ]; then
    (cd ${1} && git pull)
  else
    git clone $2 ${1}
  fi
}

while getopts "xseadtp:h" Option
do
  case $Option in
    x) X86=1;;
    s) STM32=1;;
    e) ESP32=1;;
    a) AVR=1;;
    d) DEPS=1;;
    t) TESTS="-DENABLE_TESTS=ON";;
    p) PROJECTS_HOME=${OPTARG};;
    h) help; exit 0;;
    \?) help; exit 22;;
  esac
done

shift $(($OPTIND - 1))

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

if [ -z ${CTPP2_HOME} ]; then
  export CTPP2_HOME=${XTRA_HOME}/ctpp
fi
if [ -z ${GTEST_HOME} ]; then
  export GTEST_HOME=${XTRA_HOME}/gtest
fi
if [ -z ${SPDLOG_HOME} ]; then
  export SPDLOG_HOME=${XTRA_HOME}/spdlog
fi
if [ -z ${FREERTOS_HOME} ]; then
  export FREERTOS_HOME=${XTRA_HOME}/freertos
fi
if [ -z ${LIBOPENCM3_HOME} ]; then
  export LIBOPENCM3_HOME=${XTRA_HOME}/libopencm3
fi

################################################################################

if [ "${DEPS}" -eq 1 ]; then
  clone_or_pull "${GTEST_HOME}" "https://github.com/google/googletest.git"
  clone_or_pull "${LIBOPENCM3_HOME}" "https://github.com/libopencm3/libopencm3.git"
  clone_or_pull "${FREERTOS_HOME}" "https://github.com/FreeRTOS/FreeRTOS-Kernel.git"
fi

if [ ${X86} -eq 1 ]; then
  (cd ${CMAKEHELPERS_HOME}/example \
    && mkdir -p build-x86 \
    && cd build-x86 \
    && cmake -G Ninja -DBTR_X86=1 ${TESTS} "$@" .. \
    && cmake --build .
  )
fi

if [ ${STM32} -eq 1 ]; then
  (cd ${CMAKEHELPERS_HOME}/example \
    && mkdir -p build-stm32 \
    && cd build-stm32 \
    && cmake -G Ninja -DBTR_STM32=1 ${TESTS} "$@" .. \
    && cmake --build .
  )
fi

if [ ${ESP32} -eq 1 ]; then
  (cd ${CMAKEHELPERS_HOME}/example \
    && mkdir -p build-esp32 \
    && cd build-esp32 \
    && cmake -G Ninja -DBTR_ESP32=1 ${TESTS} "$@" .. \
    && cmake --build .
  )
fi

if [ ${AVR} -eq 1 ]; then
  (cd ${CMAKEHELPERS_HOME}/example \
    && mkdir -p build-avr \
    && cd build-avr \
    && cmake -G Ninja -DBTR_AVR=1 ${TESTS} "$@" .. \
    && cmake --build .
  )
fi
