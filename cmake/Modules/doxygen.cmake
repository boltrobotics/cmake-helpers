function (build_doc)
  cmake_parse_arguments(p "" "SUFFIX;DEP" "" ${ARGN})

  set(TARGET ${PROJECT_NAME}${p_SUFFIX})

  find_package(Doxygen)

  if (DOXYGEN_FOUND)
    set(DOC_ROOT "${ROOT_SOURCE_DIR}/doc")

    if (NOT DOXYGEN_CONF_IN)
      find_program(conf_file NAMES "doxygen.conf.in" PATHS
        ${DOC_ROOT} $ENV{CMAKEHELPERS_HOME}/cmake/Modules)
    else ()
      set(conf_file ${DOXYGEN_CONF_IN})
    endif ()

    if (NOT conf_file)
      message(WARNING "No doxygen configuration found")
    else ()
      set(DOXYGEN_CONF_IN ${conf_file})
      set(DOXYGEN_CONF_OUT doxygen.conf)

      # set to override variable within configuration
      if (NOT DOXYGEN_INPUT_PATH)
        set(DOXYGEN_INPUT_PATH "${ROOT_SOURCE_DIR}")
      endif ()

      if (NOT DOXYGEN_IMAGE_PATH)
        set(DOXYGEN_IMAGE_PATH "${DOC_ROOT}")
      endif ()

      if (NOT DOXYGEN_DOTFILE_PATH)
        set(DOXYGEN_DOTFILE_PATH "${DOC_ROOT}")
      endif ()

      if (NOT DOXYGEN_OUTPUT_PATH)
        set(DOXYGEN_OUTPUT_PATH "${DOC_ROOT}")
      endif ()

      if (NOT DOXYGEN_PROJECT_NAME)
        set(DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
      endif ()

      if (NOT DOXYGEN_PROJECT_DESC)
        set(DOXYGEN_PROJECT_DESC "")
      endif ()

      if (NOT DEFINED DOXYGEN_WARN)
        set(DOXYGEN_WARN YES)
      endif ()

      if (NOT DEFINED DOXYGEN_PREPROCESSING)
        set(DOXYGEN_PREPROCESSING YES)
      endif ()

      if (NOT DEFINED DOXYGEN_EXCLUDE_EXTRA)
        set(DOXYGEN_EXCLUDE_EXTRA "")
      endif ()

      set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES "${DOXYGEN_OUTPUT_PATH}/html")
      configure_file(${DOXYGEN_CONF_IN} ${DOXYGEN_CONF_OUT} @ONLY)

      if (NOT TARGET ${TARGET})
        add_custom_target(${TARGET} ALL COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_CONF_OUT})

        if (p_DEP)
          add_dependencies(${TARGET} ${p_DEP})
        endif ()
      endif ()

    endif ()
  else ()
    message(WARNING "Doxygen not found. Documentation target not created.")
  endif ()

endfunction ()
