if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

include(init)

if (PRINT_FLAGS)
  print_compile_flags()
endif ()

####################################################################################################
# Standard set up {

function (setup_stm32)
  cmake_parse_arguments(p "" "STM32_CHIP;STM32_LINKER_SCRIPT;STM32_FLASH_SIZE;STM32_RAM_SIZE" "" ${ARGN})

  # Set chip
  if (NOT p_STM32_CHIP)
    if (NOT STM32_CHIP)
      set(STM32_CHIP stm32f103c8t6)
      message(STATUS "${BoldYellow}STM32_CHIP default: ${STM32_CHIP}${ColourReset}")
    endif ()
  else ()
    set(STM32_CHIP ${p_STM32_CHIP})
  endif ()
  set(STM32_CHIP ${STM32_CHIP} PARENT_SCOPE)

  # Set linker script
  if (NOT p_STM32_LINKER_SCRIPT)
    if (NOT STM32_LINKER_SCRIPT)
      set(STM32_LINKER_SCRIPT "${STM32_CHIP}.ld")
      message(STATUS "${BoldYellow}STM32_LINKER_SCRIPT default: ${STM32_LINKER_SCRIPT}${ColourReset}")
    endif ()
  else ()
    set(STM32_LINKER_SCRIPT ${p_STM32_LINKER_SCRIPT})
  endif ()
  set(STM32_LINKER_SCRIPT ${STM32_LINKER_SCRIPT} PARENT_SCOPE)

  # Set flash size
  if (NOT p_STM32_FLASH_SIZE)
    if (NOT STM32_FLASH_SIZE)
      set(STM32_FLASH_SIZE 64K)
      message(STATUS "${BoldYellow}STM32_FLASH_SIZE default: ${STM32_FLASH_SIZE}${ColourReset}")
    endif ()
  else ()
    set(STM32_FLASH_SIZE ${p_STM32_FLASH_SIZE})
  endif ()
  set(STM32_FLASH_SIZE ${STM32_FLASH_SIZE} PARENT_SCOPE)

  # Set ram size
  if (NOT p_STM32_RAM_SIZE)
    if (NOT STM32_RAM_SIZE)
      set(STM32_RAM_SIZE 20K)
      message(STATUS "${BoldYellow}STM32_RAM_SIZE default: ${STM32_RAM_SIZE}${ColourReset}")
    endif ()
  else ()
    set(STM32_RAM_SIZE ${p_STM32_RAM_SIZE})
  endif ()
  set(STM32_RAM_SIZE ${STM32_RAM_SIZE} PARENT_SCOPE)

  include_directories(
    "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
    "${ROOT_SOURCE_DIR}/src/common"
    "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
    "${ROOT_SOURCE_DIR}/include"
  )

  add_definitions(-DBTR_STM32=${BTR_STM32})
  add_definitions(-DSTM32${STM32_FAMILY})
endfunction()

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  cmake_parse_arguments(p "" "SUFFIX" "OBJS;SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_OBJS OBJS_LEN)
  list(LENGTH p_SRCS SRCS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    # Build object files
    add_library(${TARGET}_o OBJECT ${p_SRCS})
    set(SOURCES_OBJ ${TARGET}_o PARENT_SCOPE)

    if (OBJS_LEN GREATER 0)
      add_library(${TARGET} $<TARGET_OBJECTS:${TARGET}_o> $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_library(${TARGET} $<TARGET_OBJECTS:${TARGET}_o>)
    endif ()

    target_link_libraries(${TARGET} ${p_LIBS})
    STM32_SET_TARGET_PROPERTIES(${TARGET})
  else ()
    message(STATUS "${BoldYellow}No sources to build: ${TARGET}${ColourReset}")
    add_custom_target(${TARGET})
  endif ()
endfunction ()

# } Build library

####################################################################################################
# Build executable {

function (build_exe)
  cmake_parse_arguments(p "" "SUFFIX" "OBJS;SRCS;LIBS" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_SRCS SRCS_LEN)
  list(LENGTH p_OBJS OBJS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    message(STATUS "Target: ${TARGET}. Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    if (OBJS_LEN GREATER 0)
      add_executable(${TARGET} ${p_SRCS} $<TARGET_OBJECTS:${p_OBJS}>)
    else ()
      add_executable(${TARGET} ${p_SRCS})
    endif ()

    target_link_libraries(${TARGET} ${p_LIBS})

    # Sets -DSTM32F1 -DSTM32F103xB, -T<linker_script>.
    # Note linker script is copied and renamed to "PROJECT_NAME_flash.ld"
    STM32_SET_TARGET_PROPERTIES(${TARGET})
    STM32_ADD_HEX_BIN_TARGETS(${TARGET})
    STM32_PRINT_SIZE_OF_TARGETS(${TARGET})

    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} --build .
      --target ${TARGET}.bin)
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} --build .
      --target ${TARGET}.hex)
  else ()
    message(STATUS "${BoldYellow}No sources to build: ${TARGET}${ColourReset}")
    add_custom_target(${TARGET})
  endif ()

endfunction ()

# } Build executable 
