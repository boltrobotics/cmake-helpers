set(FREERTOS_HOME $ENV{FREERTOS_HOME})

if (NOT FREERTOS_HOME)
  message(FATAL_ERROR "FREERTOS_HOME undefined")
endif ()

if (NOT FREERTOS_HEAP_IMPL)
  set(FREERTOS_HEAP_IMPL 4)
  message(STATUS "FREERTOS_HEAP_IMPL not defined, using default: 4")
endif ()

set(HEAP_IMP_SRC_FILE heap_${FREERTOS_HEAP_IMPL}.c)

if (STM32_FAMILY STREQUAL "F0")
  set(PORT_GCC_DIR_SUFFIX "CM0")
elseif (STM32_FAMILY STREQUAL "F1")
  set(PORT_GCC_DIR_SUFFIX "CM3")
elseif (STM32_FAMILY STREQUAL "F2")
  set(PORT_GCC_DIR_SUFFIX "CM3")
elseif (STM32_FAMILY STREQUAL "F3")
  set(PORT_GCC_DIR_SUFFIX "CM4F")
elseif (STM32_FAMILY STREQUAL "F4")
  set(PORT_GCC_DIR_SUFFIX "CM4F")
elseif (STM32_FAMILY STREQUAL "F7")
  set(PORT_GCC_DIR_SUFFIX "CM7")
elseif (STM32_FAMILY STREQUAL "L0")
  set(PORT_GCC_DIR_SUFFIX "CM0")
elseif (STM32_FAMILY STREQUAL "L1")
  set(PORT_GCC_DIR_SUFFIX "CM4F")
endif ()

if (NOT FREERTOS_HEADER_FILES)
  set(FREERTOS_HEADER_FILES
    FreeRTOS.h
    StackMacros.h
    croutine.h
    deprecated_definitions.h
    event_groups.h
    list.h
    message_buffer.h
    mpu_prototypes.h
    mpu_wrappers.h
    portable.h
    projdefs.h
    queue.h
    semphr.h
    stack_macros.h
    stream_buffer.h
    task.h
    timers.h
  )
endif ()

if (NOT FREERTOS_SRC_FILES)
  set(FREERTOS_SRC_FILES
    # These are always required
    list.c
    queue.c
    tasks.c
    # Add these as needed
    #croutine.c
    #event_groups.c
    #stream_buffer.c
    #timers.c
  )
endif ()

set(PORT_ARM_SRC_FILE port.c)
set(PORTMACRO_ARM_HEADER portmacro.h)

####################################################################################################
# Find directories/files

find_file(HEAP_IMP_SOURCE ${HEAP_IMP_SRC_FILE}
  PATH_SUFFIXES MemMang
  HINTS ${FREERTOS_HOME}/FreeRTOS/Source/portable
  CMAKE_FIND_ROOT_PATH_BOTH
)

find_path(FREERTOS_COMMON_INC_DIR ${FREERTOS_HEADER_FILES}
  PATH_SUFFIXES include
  HINTS ${FREERTOS_HOME}/FreeRTOS/Source
  CMAKE_FIND_ROOT_PATH_BOTH
)

foreach(SRC ${FREERTOS_SRC_FILES})
  string(MAKE_C_IDENTIFIER "${SRC}" SRC_CLEAN)
  set(FREERTOS_${SRC_CLEAN}_FILE FREERTOS_SRC_FILE-NOTFOUND)

  find_file(FREERTOS_${SRC_CLEAN}_FILE ${SRC}
    HINTS ${FREERTOS_HOME}/FreeRTOS/Source
    CMAKE_FIND_ROOT_PATH_BOTH
  )
  list(APPEND FREERTOS_SOURCES ${FREERTOS_${SRC_CLEAN}_FILE})
endforeach()

find_file(PORT_ARM_SOURCE ${PORT_ARM_SRC_FILE}
  PATH_SUFFIXES ARM_${PORT_GCC_DIR_SUFFIX}
  HINTS ${FREERTOS_HOME}/FreeRTOS/Source/portable/GCC
  CMAKE_FIND_ROOT_PATH_BOTH
)

find_path(PORTMACRO_INC_DIR ${PORTMACRO_ARM_HEADER}
  PATH_SUFFIXES ARM_${PORT_GCC_DIR_SUFFIX}
  HINTS ${FREERTOS_HOME}/FreeRTOS/Source/portable/GCC
  CMAKE_FIND_ROOT_PATH_BOTH
)

####################################################################################################
# Update environment

set(FREERTOS_INC_DIRS
  ${FREERTOS_COMMON_INC_DIR}
  ${PORTMACRO_INC_DIR}
)

set(FREERTOS_SOURCES
  ${FREERTOS_SOURCES}
  ${PORT_ARM_SOURCE}
  ${HEAP_IMP_SOURCE}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FreeRTOS REQUIRED_VARS FREERTOS_INC_DIRS FREERTOS_SOURCES)
