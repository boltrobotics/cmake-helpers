#!/bin/bash

# Define a directory for third-party libraries.
if [ -z ${XTRA_HOME} ]; then
  XTRA_HOME=${PWD}/../xtra
fi

export GTEST_HOME=${XTRA_HOME}/gtest
export ARDUINOCMAKE_HOME=${XTRA_HOME}/arduino-cmake
export STM32CMAKE_HOME=${XTRA_HOME}/stm32-cmake
export LIBOPENCM3_HOME=${XTRA_HOME}/libopencm3
export FREERTOS_HOME=${XTRA_HOME}/FreeRTOSv10.1.1

PULL_XTRA_LIBS=0
BUILD_X86=0
BUILD_AVR=0
BUILD_STM=0
BOARD_PORT=""

help()
{
  echo "Usage: `basename $0` [-x] [-s] [-a] [-b _board_] [-c _board_cpu_] [-p _serial_port_] [-u] [-h]"
  echo -e "\t-x - build x86"
  echo -e "\t-s - build stm32 (board stm32f103c8t6)"
  echo -e "\t-a - build avr (must specify board)"
  echo -e "\t-b - board (uno, mega, etc.)"
  echo -e "\t-c - board CPU (atmega328, atmega2560, etc.)"
  echo -e "\t-p - board serial port (e.g. /dev/ttyACM0)"
  echo -e "\t-u - clone/pull dependencies from github"
  echo -e "\t-h - this help"
}

while getopts "xsab:c:p:uh" Option
do
  case $Option in
    x) BUILD_X86=1;;
    s) BUILD_STM=1;;
    a) BUILD_AVR=1;;
    b) BOARD="${OPTARG}";;
    c) BOARD_CPU="${OPTARG}";;
    p) BOARD_PORT="${OPTARG}";;
    u) PULL_XTRA_LIBS=1;;
    h) help; exit 0;;
    \?) help; exit 22;;
  esac
done

shift $(($OPTIND - 1))

# Clone repository in github or pull any changes.
function clone_or_pull {
  echo "Checking $(basename $1)"
  echo -e "\tSource: $2"
  echo -e "\tTarget: $1"

  if [ -d ${1} ]; then
    (cd ${1} && git pull)
  else
    git clone $2 ${1}
  fi
}

if [ "${PULL_XTRA_LIBS}" -eq 1 ]; then
  clone_or_pull "${GTEST_HOME}" "https://github.com/google/googletest.git"
  clone_or_pull "${ARDUINOCMAKE_HOME}" "https://github.com/queezythegreat/arduino-cmake.git"
  clone_or_pull "${STM32CMAKE_HOME}" "https://github.com/boltrobotics/stm32-cmake.git"
  clone_or_pull "${LIBOPENCM3_HOME}" "https://github.com/libopencm3/libopencm3.git"
fi

if [ ${BUILD_X86} -eq 1 ]; then
  (mkdir -p "build-x86" && cd "build-x86" \
    && cmake \
      -DBOARD_FAMILY=x86 "$@" .. \
    && make)
fi

if [ ${BUILD_AVR} -eq 1 ]; then
  if [ -z ${BOARD} ]; then
    echo "Must specify AVR board" 
    help
    exit -1
  else
    (mkdir -p "build-avr" && cd "build-avr" \
      && cmake \
        -DBOARD_FAMILY=avr \
        -DBOARD_PORT=${BOARD_PORT} \
        -DBOARD=${BOARD} \
        -DBOARD_CPU=${BOARD_CPU} "$@" .. \
      && make)
  fi
fi

if [ ${BUILD_STM} -eq 1 ]; then
  (mkdir -p "build-stm32" && cd "build-stm32" \
    && cmake \
      -DBOARD_FAMILY=stm32 \
      -DSTM32_CHIP=stm32f103c8t6 \
      -DSTM32_FLASH_SIZE=64K \
      -DSTM32_RAM_SIZE=20K "$@" .. \
    && make)
fi
