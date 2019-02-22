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

X86=0
STM32=0
AVR=0
ARD=0
BOARD_PORT=""
PULL_XTRA_LIBS=0

help()
{
  echo -n "Usage: `basename $0` [-x] [-s] [-r] [-a] "
  echo "[-b _board_] [-c _board_cpu_] [-p _serial_port_] [-u] [-h]"
  echo -e "\t-x - x86"
  echo -e "\t-s - stm32"
  echo -e "\t-r - avr (specify: -DAVR_MCU=atmega2560? -DAVR_H_FUSE=0x99? -DAVR_L_FUSE=0x42?)"
  echo -e "\t-a - arduino (specify board)"
  echo -e "\t-b - arduino board (uno, mega, etc.)"
  echo -e "\t-c - arduino board CPU (atmega328, atmega2560, etc.)"
  echo -e "\t-p - arduino board serial port (e.g. /dev/ttyACM0)"
  echo -e "\t-u - clone/pull dependencies from github"
  echo -e "\t-h - this help"
}

while getopts "xsrab:c:p:uh" Option
do
  case $Option in
    x) X86=1;;
    s) STM32=1;;
    r) AVR=1;;
    a) ARD=1;;
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

if [ ${X86} -eq 1 ]; then
  (mkdir -p "build-x86" && cd "build-x86" \
    && cmake \
      -DBTR_X86=1 \
      "$@" .. \
    && make)
fi

if [ ${STM32} -eq 1 ]; then
  (mkdir -p "build-stm32" && cd "build-stm32" \
    && cmake \
      -DBTR_STM32=1 \
      -DSTM32_CHIP=stm32f103c8t6 \
      -DSTM32_FLASH_SIZE=64K \
      -DSTM32_RAM_SIZE=20K \
      "$@" .. \
    && make)
fi

if [ ${AVR} -eq 1 ]; then
  (mkdir -p "build-avr" && cd "build-avr" \
    && cmake \
      -DBTR_AVR=1 \
      "$@" .. \
    && make)
fi

if [ ${ARD} -eq 1 ]; then
  if [ -z ${BOARD} ]; then
    echo "Must specify Arduino board" 
    help
    exit -1
  else
    (mkdir -p "build-ard" && cd "build-ard" \
      && cmake \
        -DBTR_ARD=1 \
        -DBOARD_PORT=${BOARD_PORT} \
        -DBOARD=${BOARD} \
        -DBOARD_CPU=${BOARD_CPU} \
        "$@" .. \
      && make)
  fi
fi
