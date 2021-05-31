# Adapted from stm32-cmake project

GET_FILENAME_COMPONENT(THIS_FILE_DIR ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
set(CMAKE_MODULE_PATH ${THIS_FILE_DIR} ${CMAKE_MODULE_PATH})

if (NOT TOOLCHAIN_PREFIX)
  set(TOOLCHAIN_PREFIX "/usr")
  message(STATUS "No TOOLCHAIN_PREFIX specified, using default: " ${TOOLCHAIN_PREFIX})
else()
  file(TO_CMAKE_PATH "${TOOLCHAIN_PREFIX}" TOOLCHAIN_PREFIX)
endif ()

if (NOT TARGET_TRIPLET)
  set(TARGET_TRIPLET "arm-none-eabi")
  message(STATUS "No TARGET_TRIPLET specified, using default: " ${TARGET_TRIPLET})
endif ()

################################################################################
# Set up STM32 parameters

set(STM32_SUPPORTED_FAMILIES L0 L1 L4 F0 F1 F2 F3 F4 F7 CACHE INTERNAL "stm32 supported families")

if (STM32_CHIP)
  set(STM32_CHIP "${STM32_CHIP}" CACHE STRING "STM32 chip to build for")
endif ()

if (NOT STM32_FAMILY)
  message(STATUS "No STM32_FAMILY specified, trying to get it from STM32_CHIP")

  if (NOT STM32_CHIP)
    set(STM32_FAMILY "F1" CACHE INTERNAL "stm32 family")
    message(STATUS
      "Neither STM32_FAMILY nor STM32_CHIP specified, using default STM32_FAMILY: ${STM32_FAMILY}")
  else()
    string(REGEX REPLACE "^[sS][tT][mM]32(([fF][0-47])|([lL][0-14])|([tT])|([wW])).+$" "\\1"
      STM32_FAMILY ${STM32_CHIP})
    string(TOUPPER ${STM32_FAMILY} STM32_FAMILY)
    message(STATUS "Selected STM32 family: ${STM32_FAMILY}")
  endif ()
endif ()

string(TOUPPER "${STM32_FAMILY}" STM32_FAMILY)
list(FIND STM32_SUPPORTED_FAMILIES "${STM32_FAMILY}" FAMILY_INDEX)

if (FAMILY_INDEX EQUAL -1)
  message(FATAL_ERROR "Unsupported STM32 family: ${STM32_FAMILY}")
endif ()

################################################################################
# Set up toolchain parameters

set(TOOLCHAIN_BIN_DIR "${TOOLCHAIN_PREFIX}/bin")
set(TOOLCHAIN_INC_DIR "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/include")
set(TOOLCHAIN_LIB_DIR "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/lib")
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_C_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}")
set(CMAKE_ASM_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")
set(CMAKE_OBJCOPY "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy${TOOL_EXECUTABLE_SUFFIX}"
  CACHE INTERNAL "objcopy tool")
set(CMAKE_OBJDUMP "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump${TOOL_EXECUTABLE_SUFFIX}"
  CACHE INTERNAL "objdump tool")
set(CMAKE_SIZE "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-size${TOOL_EXECUTABLE_SUFFIX}"
  CACHE INTERNAL "size tool")
set(CMAKE_DEBUGER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gdb${TOOL_EXECUTABLE_SUFFIX}"
  CACHE INTERNAL "debuger")
set(CMAKE_CPPFILT "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-c++filt${TOOL_EXECUTABLE_SUFFIX}"
  CACHE INTERNAL "C++filt")

# Removed stm32-cmake defaults "-Og -g" as it causes BluePill to lock up
set(CMAKE_C_FLAGS_DEBUG "" CACHE INTERNAL "c flags debug")
set(CMAKE_CXX_FLAGS_DEBUG "" CACHE INTERNAL "cxx flags debug")

# Removed stm32-cmake defaults "-Os -flto" causes symbol vTaskSwitchContext disappear
set(CMAKE_C_FLAGS_RELEASE "" CACHE INTERNAL "c flags release")
set(CMAKE_CXX_FLAGS_RELEASE "" CACHE INTERNAL "cxx compiler flags release")

if (CMAKE_BUILD_TYPE MATCHES Release)
  set(O_FLAGS "-Os")
endif ()
if (CMAKE_BUILD_TYPE MATCHES Debug)
  # WARNING: Do NOT change optimization level to -00, BluePill will get into hard fault handler
  set(O_FLAGS "-Os -g")
endif ()

set(A_FLAGS "-mthumb -mcpu=cortex-m3 -mabi=aapcs")
set(M_FLAGS "${A_FLAGS} -msoft-float -mfix-cortex-m3-ldrd -MD")
set(F_FLAGS "-fno-builtin -ffunction-sections -fdata-sections -fno-common -fomit-frame-pointer")
set(F_FLAGS "${F_FLAGS} -fno-unroll-loops -ffast-math -ftree-vectorize -fno-exceptions")
set(F_FLAGS "${F_FLAGS} -fno-unwind-tables")
set(W_FLAGS "-Wall -Wextra -Wshadow -Wredundant-decls")
set(CMAKE_CXX_FLAGS "${O_FLAGS} ${M_FLAGS} ${F_FLAGS} ${W_FLAGS}" CACHE INTERNAL "cxx flags")
set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS}" CACHE INTERNAL "c flags")

set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m3 -x assembler-with-cpp" CACHE INTERNAL "asm flags")
set(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE INTERNAL "asm flags debug")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "exe linker flags debug")
set(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "asm flags release")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto" CACHE INTERNAL "linker flags release")
set(CMAKE_MODULE_LINKER_FLAGS "${A_FLAGS}" CACHE INTERNAL "module linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "${A_FLAGS}" CACHE INTERNAL "shared linker flags")

# From book: -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group")
set(LD_FLAGS "--static -nostartfiles -specs=nosys.specs -mthumb -mcpu=cortex-m3 -mabi=aapcs")
set(LD_FLAGS "${LD_FLAGS} -Wl,-Map=${PROJECT_NAME}.map -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${LD_FLAGS}" CACHE INTERNAL "executable linker flags")

set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}" ${EXTRA_FIND_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

function(print_compile_flags)
  message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
  message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
  message(STATUS "CMAKE_C_FLAGS_DEBUG: ${CMAKE_C_FLAGS_DEBUG}")
  message(STATUS "CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
  message(STATUS "CMAKE_C_FLAGS_RELEASE: ${CMAKE_C_FLAGS_RELEASE}")
  message(STATUS "CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")
  message(STATUS "CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
  message(STATUS "CMAKE_MODULE_LINKER_FLAGS: ${CMAKE_MODULE_LINKER_FLAGS}")
  message(STATUS "CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}")
  message(STATUS "CMAKE_STATIC_LINKER_FLAGS: ${CMAKE_STATIC_LINKER_FLAGS}")
  message(STATUS "STM32_LINKER_SCRIPT: ${STM32_LINKER_SCRIPT}")
endfunction()

### gcc_stm32f1.cmake {

set(STM32_CHIP_TYPES
  100xB 100xE 101x6 101xB 101xE 101xG 102x6 102xB 103x6 103xB 103xE 103xG 105xC 107xC
  CACHE INTERNAL "stm32f1 chip types")
set(STM32_CODES
  "100.[468B]" "100.[CDE]" "101.[46]" "101.[8B]" "101.[CDE]" "101.[FG]" "102.[46]" "102.[8B]"
  "103.[46]" "103.[8B]" "103.[CDE]" "103.[FG]" "105.[8BC]" "107.[BC]")

macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
  string(REGEX REPLACE "^[sS][tT][mM]32[fF](10[012357].[468BCDEFG]).*$" "\\1" STM32_CODE ${CHIP})
  set(INDEX 0)

  foreach(C_TYPE ${STM32_CHIP_TYPES})
    list(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)

    if (STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
      set(RESULT_TYPE ${C_TYPE})
    endif()
    math(EXPR INDEX "${INDEX}+1")
  endforeach()

  set(${CHIP_TYPE} ${RESULT_TYPE})
endmacro()

macro(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE CCRAM_SIZE)
  string(REGEX REPLACE "^[sS][tT][mM]32[fF](10[012357]).[468BCDEFG].*$" "\\1"
    STM32_CODE ${CHIP})
  string(REGEX REPLACE "^[sS][tT][mM]32[fF]10[012357].([468BCDEFG]).*$" "\\1"
    STM32_SIZE_CODE ${CHIP})

  if (STM32_SIZE_CODE STREQUAL "4")
    set(FLASH "16K")
  elseif (STM32_SIZE_CODE STREQUAL "6")
    set(FLASH "32K")
  elseif (STM32_SIZE_CODE STREQUAL "8")
    set(FLASH "64K")
  elseif (STM32_SIZE_CODE STREQUAL "B")
    set(FLASH "128K")
  elseif (STM32_SIZE_CODE STREQUAL "C")
    set(FLASH "256K")
  elseif (STM32_SIZE_CODE STREQUAL "D")
    set(FLASH "384K")
  elseif (STM32_SIZE_CODE STREQUAL "E")
    set(FLASH "512K")
  elseif (STM32_SIZE_CODE STREQUAL "F")
    set(FLASH "768K")
  elseif (STM32_SIZE_CODE STREQUAL "G")
    set(FLASH "1024K")
  endif ()

  STM32_GET_CHIP_TYPE(${CHIP} TYPE)

  if (${TYPE} STREQUAL 100xB)
    if ((STM32_SIZE_CODE STREQUAL "4") OR (STM32_SIZE_CODE STREQUAL "6"))
      set(RAM "4K")
    else()
      set(RAM "8K")
    endif ()
  elseif (${TYPE} STREQUAL 100xE)
    if (STM32_SIZE_CODE STREQUAL "C")
      set(RAM "24K")
    else()
      set(RAM "32K")
    endif ()
  elseif (${TYPE} STREQUAL 101x6)
    if (STM32_SIZE_CODE STREQUAL "4")
      set(RAM "4K")
    else()
      set(RAM "6K")
    endif ()
  elseif (${TYPE} STREQUAL 101xB)
    if (STM32_SIZE_CODE STREQUAL "8")
      set(RAM "10K")
    else()
      set(RAM "16K")
    endif ()
  elseif (${TYPE} STREQUAL 101xE)
    if (STM32_SIZE_CODE STREQUAL "C")
      set(RAM "32K")
    else()
      set(RAM "48K")
    endif ()
  elseif (${TYPE} STREQUAL 101xG)
    set(RAM "80K")
  elseif (${TYPE} STREQUAL 102x6)
    if (STM32_SIZE_CODE STREQUAL "4")
      set(RAM "4K")
    else()
      set(RAM "6K")
    endif ()
  elseif (${TYPE} STREQUAL 102xB)
    if (STM32_SIZE_CODE STREQUAL "8")
      set(RAM "10K")
    else()
      set(RAM "16K")
    endif ()
  elseif (${TYPE} STREQUAL 103x6)
    if (STM32_SIZE_CODE STREQUAL "4")
      set(RAM "6K")
    else()
      set(RAM "10K")
    endif ()
  elseif (${TYPE} STREQUAL 103xB)
    set(RAM "20K")
  elseif (${TYPE} STREQUAL 103xE)
    if (STM32_SIZE_CODE STREQUAL "C")
      set(RAM "48K")
    else()
      set(RAM "54K")
    endif ()
  elseif (${TYPE} STREQUAL 103xG)
    set(RAM "96K")
  elseif (${TYPE} STREQUAL 105xC)
    set(RAM "64K")
  elseif (${TYPE} STREQUAL 107xC)
    set(RAM "64K")
  endif ()

  set(${FLASH_SIZE} ${FLASH})
  set(${RAM_SIZE} ${RAM})
  set(${CCRAM_SIZE} "0K")
endmacro()

function(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
  list(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)

  if (TYPE_INDEX EQUAL -1)
    message(FATAL_ERROR "Invalid/unsupported STM32F1 chip type: ${CHIP_TYPE}")
  endif ()

  get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)

  if (TARGET_DEFS)
    set(TARGET_DEFS "STM32F1;STM32F${CHIP_TYPE};${TARGET_DEFS}")
  else()
    set(TARGET_DEFS "STM32F1;STM32F${CHIP_TYPE}")
  endif ()
  set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()

### } gcc_stm32f1.cmake

###
function(STM32_ADD_HEX_BIN_TARGETS TARGET)
  if (EXECUTABLE_OUTPUT_PATH)
    set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
  else()
    set(FILENAME "${TARGET}")
  endif ()
  add_custom_target(${TARGET}.hex DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY}
    -Oihex ${FILENAME} ${FILENAME}.hex)
  add_custom_target(${TARGET}.bin DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY}
    -Obinary ${FILENAME} ${FILENAME}.bin)
endfunction()

###

function(STM32_ADD_DUMP_TARGET TARGET)
  if (EXECUTABLE_OUTPUT_PATH)
    set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
  else()
    set(FILENAME "${TARGET}")
  endif ()
  add_custom_target(${TARGET}.dump DEPENDS ${TARGET} COMMAND ${CMAKE_OBJDUMP} -x -D -S -s 
    ${FILENAME} | ${CMAKE_CPPFILT} > ${FILENAME}.dump)
endfunction()

###

function(STM32_PRINT_SIZE_OF_TARGETS TARGET)
  if (EXECUTABLE_OUTPUT_PATH)
    set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
  else()
    set(FILENAME "${TARGET}")
  endif ()
  add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_SIZE} ${FILENAME})
endfunction()

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)

###

function(STM32_SET_FLASH_PARAMS
    TARGET STM32_FLASH_SIZE STM32_RAM_SIZE STM32_CCRAM_SIZE STM32_MIN_STACK_SIZE
    STM32_MIN_HEAP_SIZE STM32_FLASH_ORIGIN STM32_RAM_ORIGIN STM32_CCRAM_ORIGIN)

  if (NOT STM32_LINKER_SCRIPT)
    message(FATAL_ERROR "No linker script specified")
  else()
    configure_file(${STM32_LINKER_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld)
  endif ()

  get_target_property(TARGET_LD_FLAGS ${TARGET} LINK_FLAGS)

  if (TARGET_LD_FLAGS)
    set(TARGET_LD_FLAGS "\"-T${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld\" ${TARGET_LD_FLAGS}")
  else()
    set(TARGET_LD_FLAGS "\"-T${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld\"")
  endif ()
  set_target_properties(${TARGET} PROPERTIES LINK_FLAGS ${TARGET_LD_FLAGS})
endfunction()

### 

function(STM32_SET_FLASH_PARAMS TARGET FLASH_SIZE RAM_SIZE)
  if (NOT STM32_FLASH_ORIGIN)
    set(STM32_FLASH_ORIGIN "0x08000000")
  endif ()
  if (NOT STM32_RAM_ORIGIN)
    set(STM32_RAM_ORIGIN "0x20000000")
  endif ()
  if (NOT STM32_MIN_STACK_SIZE)
    set(STM32_MIN_STACK_SIZE "0x200")
  endif ()
  if (NOT STM32_MIN_HEAP_SIZE)
    set(STM32_MIN_HEAP_SIZE "0")
  endif ()
  if (NOT STM32_CCRAM_ORIGIN)
    set(STM32_CCRAM_ORIGIN "0x10000000")
  endif ()

  if (NOT STM32_LINKER_SCRIPT)
    message(FATAL_ERROR "No linker script specified, generating default")
  else()
    configure_file(${STM32_LINKER_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld)
  endif ()

  get_target_property(TARGET_LD_FLAGS ${TARGET} LINK_FLAGS)

  if (TARGET_LD_FLAGS)
    set(TARGET_LD_FLAGS "\"-T${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld\" ${TARGET_LD_FLAGS}")
  else()
    set(TARGET_LD_FLAGS "\"-T${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld\"")
  endif ()
  set_target_properties(${TARGET} PROPERTIES LINK_FLAGS ${TARGET_LD_FLAGS})
endfunction()

###

function(STM32_SET_TARGET_PROPERTIES TARGET)
  STM32_GET_CHIP_TYPE(${STM32_CHIP} STM32_CHIP_TYPE)
  STM32_SET_CHIP_DEFINITIONS(${TARGET} ${STM32_CHIP_TYPE})

  if (((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE)) AND (NOT STM32_CHIP))
    message(FATAL_ERROR "Please specify either STM32_CHIP or STM32_FLASH_SIZE/STM32_RAM_SIZE")
  endif ()

  if ((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE))
    STM32_GET_CHIP_PARAMETERS(${STM32_CHIP} STM32_FLASH_SIZE STM32_RAM_SIZE STM32_CCRAM_SIZE)

    if ((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE))
      message(FATAL_ERROR "Unknown chip: ${STM32_CHIP}")
    endif ()
  endif ()

  STM32_SET_FLASH_PARAMS(${TARGET} ${STM32_FLASH_SIZE} ${STM32_RAM_SIZE})

  message(STATUS
    "${STM32_CHIP} has ${STM32_FLASH_SIZE}iB of flash memory and ${STM32_RAM_SIZE}iB of RAM")
endfunction()

###

function(STM32_SET_HSE_VALUE TARGET STM32_HSE_VALUE)
  get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)

  if (TARGET_DEFS)
    set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE};${TARGET_DEFS}")
  else()
    set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE}")
  endif ()

  set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()

###

macro(STM32_GENERATE_LIBRARIES NAME SOURCES LIBRARIES)
  string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)

  foreach(CHIP_TYPE ${STM32_CHIP_TYPES})
    string(TOLOWER ${CHIP_TYPE} CHIP_TYPE_LOWER)
    list(APPEND ${LIBRARIES} ${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER})
    add_library(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${SOURCES})
    STM32_SET_CHIP_DEFINITIONS(${NAME}_${STM32_FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${CHIP_TYPE})
  endforeach()
endmacro()
