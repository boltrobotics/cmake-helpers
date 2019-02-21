find_package(Doxygen)

if (DOXYGEN_FOUND)
  if (NOT DOXYGEN_CONF_IN)
    find_program(conf_file NAMES "doxygen.conf.in" PATHS ${CMAKE_CURRENT_SOURCE_DIR})
  else ()
    set(conf_file ${DOXYGEN_CONF_IN})
  endif ()

  if (NOT conf_file)
    message(WARNING "No doxygen configuration found: '${CMAKE_CURRENT_SOURCE_DIR}/doxygen.conf.in'")
  else ()
    set(DOXYGEN_CONF_IN ${conf_file})
    set(DOXYGEN_CONF_OUT doxygen.conf)

    # set to override variable within configuration
    if (NOT DOXYGEN_INPUT_PATH)
      set(DOXYGEN_INPUT_PATH "\"${CMAKE_CURRENT_SOURCE_DIR}\"")
    endif ()

    if (NOT DOXYGEN_OUTPUT_PATH)
      set(DOXYGEN_OUTPUT_PATH "\"${CMAKE_CURRENT_BINARY_DIR}\"")
    endif ()

    if (NOT DOXYGEN_IMAGE_PATH)
      set(DOXYGEN_IMAGE_PATH "\"${CMAKE_CURRENT_SOURCE_DIR}\"")
    endif ()

    if (NOT DOXYGEN_DOTFILE_PATH)
      set(DOXYGEN_DOTFILE_PATH "\"${CMAKE_CURRENT_SOURCE_DIR}\"")
    endif ()

    set_property(
      DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${CMAKE_CURRENT_BINARY_DIR}/html")

    configure_file(${DOXYGEN_CONF_IN} ${DOXYGEN_CONF_OUT} @ONLY)

    add_custom_target(
      docu COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_CONF_OUT} COMMENT "Create HTML documentation")
  endif ()
else ()
  message(WARNING "Doxygen not found. Documentation target not created.")
endif ()
