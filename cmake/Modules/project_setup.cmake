macro(set_param VAR KEY)
  if (p_${VAR})
    set(${VAR} "${KEY} ${p_${VAR}}")
  else ()
    set(${VAR} "${KEY}  \"\"")
  endif ()
endmacro()

function(download_project)
  cmake_parse_arguments(p "" "PREFIX;HOME;URL;BUILD_IN;SRC_DIR;BIN_DIR"
    "CONFIG_CMD;BUILD_CMD;INSTALL_CMD;TEST_CMD;LOG_BUILD" ${ARGN})

  set(WORK_DIR "${CMAKE_BINARY_DIR}/${p_PREFIX}")
  set(PREFIX "${p_PREFIX}")
  set(HOME "${p_HOME}")
  set(URL "${p_URL}")
  set(SOURCE_DIR "SOURCE_DIR  \"${p_SRC_DIR}\"")

  # BUILD_IN and BINARY_DIR are mutually exclusive
  #
  if (NOT p_BUILD_IN)
    set(BINARY_DIR "BINARY_DIR  \"${p_BIN_DIR}\"")
  endif ()

  set_param(CONFIG_CMD CONFIGURE_COMMAND)
  set_param(BUILD_CMD BUILD_COMMAND)
  set_param(BUILD_IN BUILD_IN_SOURCE)
  set_param(INSTALL_CMD INSTALL_COMMAND)
  set_param(TEST_CMD TEST_COMMAND)
  set_param(LOG_BUILD LOG_BUILD)

  set(CMAKE_FIND_ROOT_PATH /)
  find_file(EXTERNAL_PROJ_TPL project_download.cmake.in PATHS ${CMAKE_MODULE_PATH} NO_DEFAULT_PATH)

  configure_file(${EXTERNAL_PROJ_TPL} "${WORK_DIR}/CMakeLists.txt")

  execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result WORKING_DIRECTORY "${WORK_DIR}")

  if (result)
    message(FATAL_ERROR "Configure step for ${p_PREFIX} failed: ${result}")
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result WORKING_DIRECTORY "${WORK_DIR}")

  if (result)
    message(FATAL_ERROR "Download step for ${p_PREFIX} failed: ${result}")
  endif()

endfunction()

####################################################################################################
#
#
function(add_project)
  cmake_parse_arguments(
    p "" "PREFIX;HOME;INC_DIR;SRC_DIR;BIN_DIR;LIB_DIR;LIB_NAME;BUILD_CMD;FORCE_UPDATE" "" ${ARGN})

  # Home directory must be defined. This is where the dependency will be downloaded to if the
  # directory does not already exist.
  #
  if (NOT p_HOME)
    message(FATAL_ERROR "${p_PREFIX} HOME undefined")
  endif ()
  message(STATUS "${p_PREFIX} home directory: ${p_HOME}")

  # Set binary directory
  #
  if (NOT p_BIN_DIR)
    set(${p_PREFIX}_BINARY_DIR "${CMAKE_BINARY_DIR}/${p_PREFIX}/build")
  else ()
    set(${p_PREFIX}_BINARY_DIR "${p_BIN_DIR}")
  endif()
  set(${p_PREFIX}_BINARY_DIR "${${p_PREFIX}_BINARY_DIR}" PARENT_SCOPE)
  message(STATUS "${p_PREFIX} binary directory: ${${p_PREFIX}_BINARY_DIR}")

  # Set source directory
  #
  if (NOT p_SRC_DIR)
    set(${p_PREFIX}_SOURCE_DIR "${p_HOME}")
  else ()
    set(${p_PREFIX}_SOURCE_DIR "${p_SRC_DIR}")
  endif()
  set(${p_PREFIX}_SOURCE_DIR "${${p_PREFIX}_SOURCE_DIR}" PARENT_SCOPE)
  message(STATUS "${p_PREFIX} source directory: ${${p_PREFIX}_SOURCE_DIR}")

  # If home directory does not exist, try to download and build the external project.
  #
  if (NOT IS_DIRECTORY "${p_HOME}" OR p_FORCE_UPDATE)
    message(STATUS "${p_PREFIX} download directory: ${p_HOME}")
    download_project(${ARGN})
  endif ()

  # Set include directory variable
  #
  if (NOT p_INC_DIR)
    set(${p_PREFIX}_INC_DIR "${p_HOME}/include")
  else ()
    set(${p_PREFIX}_INC_DIR "${p_INC_DIR}")
  endif ()
  set(${p_PREFIX}_INC_DIR "${${p_PREFIX}_INC_DIR}" PARENT_SCOPE)
  message(STATUS "${p_PREFIX} include directory: ${${p_PREFIX}_INC_DIR}")

  # Set library directory
  #
  if (NOT p_LIB_DIR)
    set(${p_PREFIX}_LIB_DIR  "${${p_PREFIX}_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
  else ()
    set(${p_PREFIX}_LIB_DIR  "${p_LIB_DIR}")
  endif ()
  set(${p_PREFIX}_LIB_DIR  "${${p_PREFIX}_LIB_DIR}" PARENT_SCOPE)
  message(STATUS "${p_PREFIX} library directory: ${${p_PREFIX}_LIB_DIR}")

  # Set library name without prefix/suffix (i.e. lib[library name].a)
  #
  if (NOT p_LIB_NAME)
    set(${p_PREFIX}_LIB_NAME "${p_PREFIX}")
  else ()
    set(${p_PREFIX}_LIB_NAME "${p_LIB_NAME}")
  endif ()
  set(${p_PREFIX}_LIB_NAME "${${p_PREFIX}_LIB_NAME}" PARENT_SCOPE)
  message(STATUS "${p_PREFIX} library name: ${${p_PREFIX}_LIB_NAME}")

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(${p_PREFIX} REQUIRED_VARS
    ${p_PREFIX}_LIB_DIR ${p_PREFIX}_INC_DIR)

  # For cross-compiled (arm) project, cmake sets root filesystem at /usr/local/arm-non-eabi.
  # Set the root to system root.
  set(CMAKE_FIND_ROOT_PATH /)
  find_library(
    ${p_PREFIX}_LIB_PATH ${${p_PREFIX}_LIB_NAME} ${${p_PREFIX}_LIB_DIR})

  #set(${p_PREFIX}_LIB_PATH "${${p_PREFIX}_LIB_DIR}/${${p_PREFIX}_LIB_NAME}" PARENT_SCOPE)

  if (NOT TARGET ${p_PREFIX})
    #if (NOT ${p_PREFIX}_${CMAKE_BUILD_TYPE}_ALREADY_ADDED)
    set(${p_PREFIX}_${CMAKE_BUILD_TYPE}_ALREADY_ADDED 1)
    set(${p_PREFIX}_${CMAKE_BUILD_TYPE}_ALREADY_ADDED 1 PARENT_SCOPE)

    # Add subdirectory only if there is no custom command to build third-party project
    #
    if (NOT p_BUILD_CMD)
      add_subdirectory("${${p_PREFIX}_SOURCE_DIR}" "${${p_PREFIX}_BINARY_DIR}")
      message(STATUS "${p_PREFIX} sudbdirectory added to build")
    else ()
      message(STATUS "${p_PREFIX} uses custom build command: ${p_BUILD_CMD}")
    endif ()
  else ()
    message(STATUS "${p_PREFIX} already added to build")
  endif()

endfunction()
