if (SUBPROJECT_NAME)
  project(${SUBPROJECT_NAME})
else ()
  project(${PROJECT_NAME})
endif ()

include(init)

####################################################################################################
# stm32 project {

if (PRINT_FLAGS)
  print_compile_flags()
endif ()

include_directories(
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
  "${ROOT_SOURCE_DIR}/src/common"
  "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
  "${ROOT_SOURCE_DIR}/include"
)

file(GLOB_RECURSE SOURCES_SCAN
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.c"
  "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}/*.cpp"
  "${ROOT_SOURCE_DIR}/src/common/*.c"
  "${ROOT_SOURCE_DIR}/src/common/*.cpp")
list(APPEND SOURCES ${SOURCES_SCAN})

list(LENGTH SOURCES SOURCES_LEN)

if (SOURCES_LEN GREATER 0)
  if (BUILD_LIB AND BUILD_EXE)
    message(FATAL_ERROR "Both BUILD_LIB and BUILD_EXE are ON. Use one or the other")
  endif ()

  add_definitions(-DSTM32${STM32_FAMILY} -D${BOARD_FAMILY})

  if (NOT EXISTS ${MAIN_SRC})
    set(MAIN_SRC "")
  else ()
    list(REMOVE_ITEM SOURCES ${MAIN_SRC})
  endif ()

  list(LENGTH SOURCES SOURCES_LEN)

  ##############################################################################
  # Build library
  message(STATUS "BUILD_LIB: ${BUILD_LIB}")
  if (BUILD_LIB)
    set(TARGET ${PROJECT_NAME}${LIB_SUFFIX})

    if (SOURCES_LEN GREATER 0)
      add_library(${TARGET} ${SOURCES})
      target_link_libraries(${TARGET} ${LIB_LIBRARIES})
      STM32_SET_TARGET_PROPERTIES(${TARGET})
    else ()
      message(STATUS "Cannot build ${TARGET} without sources")
    endif ()
  endif ()

  ##############################################################################
  # Build executable
  message(STATUS "BUILD_EXE: ${BUILD_EXE}")
  if (BUILD_EXE)
    set(TARGET ${PROJECT_NAME}${EXE_SUFFIX})

    add_executable(${TARGET} ${MAIN_SRC} ${SOURCES})
    target_link_libraries(${TARGET} ${EXE_LIBRARIES})

    # Sets -DSTM32F1 -DSTM32F103xB, -T<linker_script>.
    # Note linker script is copied and renamed to "PROJECT_NAME_flash.ld"
    STM32_SET_TARGET_PROPERTIES(${TARGET})
    STM32_ADD_HEX_BIN_TARGETS(${TARGET})
    STM32_PRINT_SIZE_OF_TARGETS(${TARGET})

    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} --build .
      --target ${TARGET}.bin)
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} --build .
      --target ${TARGET}.hex)
  endif ()

else ()
  message(STATUS "Project ${PROJECT_NAME} has no sources to build")
endif ()

# } stm32 project
