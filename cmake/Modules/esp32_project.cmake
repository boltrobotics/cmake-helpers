message(STATUS "Processing: esp32_project.cmake")
include(init)
include(${IDF_PATH}/tools/cmake/idf.cmake)

####################################################################################################
# Standard set up {

#add_definitions(-DBTR_ESP32=${BTR_ESP32})

# } Standard setup

####################################################################################################
# Build library

function (build_lib)
  build_exe(BUILD_LIB ${ARGV})
endfunction ()

# } Build library

####################################################################################################
# Build executable {

function (build_exe)
  cmake_parse_arguments(p "BUILD_LIB" "SUFFIX;ESP_TARGET;SDKCONFIG_DEFAULTS"
    "OBJS;SRCS;LIBS;INC_DIRS;DEPS;COMPONENTS" ${ARGN})

  set(BTARGET ${PROJECT_NAME}${p_SUFFIX})
  list(LENGTH p_OBJS OBJS_LEN)
  list(LENGTH p_SRCS SRCS_LEN)
  list(LENGTH p_DEPS DEPS_LEN)

  if (SRCS_LEN GREATER 0 OR OBJS_LEN GREATER 0)
    if (NOT p_ESP_TARGET)
      set(p_ESP_TARGET esp32)
    endif ()
    if (NOT p_SDKCONFIG_DEFAULTS)
      set(p_SDKCONFIG_DEFAULTS ${PROJECT_SOURCE_DIR}/sdkconfig.defaults)

      if (NOT EXISTS ${p_SDKCONFIG_DEFAULTS})
        file(TOUCH "${p_SDKCONFIG_DEFAULTS}")
      endif ()
    endif ()
    if (p_BUILD_LIB)
      set(BUILD_DIR ${LIBRARY_OUTPUT_PATH})
    else ()
      set(BUILD_DIR ${EXECUTABLE_OUTPUT_PATH})
    endif ()

    message(STATUS "Target: ${BTARGET}, ESP: ${p_ESP_TARGET}. "
      "Sources: ${p_SRCS}. OBJS: ${p_OBJS}")

    idf_build_process(${p_ESP_TARGET}
      # try and trim the build; additional components
      # will be included as needed based on dependency tree
      #
      # although esptool_py does not generate static library,
      # processing the component is needed for flashing related
      # targets and file generation
      COMPONENTS ${p_COMPONENTS}
      SDKCONFIG_DEFAULTS ${p_SDKCONFIG_DEFAULTS}
      BUILD_DIR ${BUILD_DIR}
      )

    # INFO: Why ESP-IDF doesn't include idf headers or generate sdkconfig.h when using generator   
    # expression with library objects?
    #add_library(${BTARGET}_o OBJECT ${p_SRCS})
    #set(SOURCES_OBJ ${BTARGET}_o PARENT_SCOPE)

    if (OBJS_LEN GREATER 0)
      #add_executable(${BTARGET} $<TARGET_OBJECTS:${BTARGET_OBJS}> $<TARGET_OBJECTS:${p_OBJS}>)

      if (p_BUILD_LIB)
        add_library(${BTARGET} STATIC ${p_SRCS} $<TARGET_OBJECTS:${p_OBJS}>)
      else ()
        add_executable(${BTARGET} ${p_SRCS} $<TARGET_OBJECTS:${p_OBJS}>)
      endif ()
    else ()
      if (p_BUILD_LIB)
        add_library(${BTARGET} STATIC ${p_SRCS})
      else ()
        add_executable(${BTARGET} ${p_SRCS})
      endif ()
    endif ()

    target_link_libraries(${BTARGET} ${p_LIBS})

    target_include_directories(${BTARGET} PRIVATE
      "${ROOT_SOURCE_DIR}/src/${BOARD_FAMILY}"
      "${ROOT_SOURCE_DIR}/src/common"
      "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}"
      "${ROOT_SOURCE_DIR}/include"
      "${p_INC_DIRS}"
    )

    target_compile_options(${BTARGET} PRIVATE "-mfix-esp32-psram-cache-issue")

    idf_build_executable(${BTARGET})

  else ()
    message(STATUS "${Yellow}No sources to build${ColourReset}")
    add_custom_target(${BTARGET})
  endif ()

  if (DEPS_LEN GREATER 0)
    add_dependencies(${BTARGET} ${p_DEPS})
  endif ()
endfunction ()

# } Build executable 
