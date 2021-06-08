function(add_logger)
  cmake_parse_arguments(p "" "INC_DIR;SRC_DIR;SCT_DIR;VIEWER_NAME" "" ${ARGN})

  set(VM "boltalog-autogen")
  set(NAME logger)
  set(TMPL_DIR "$ENV{BOLTALOG_HOME}/template")
  set(BASE "${TMPL_DIR}/${NAME}")
  set(VIEWER_BASE "${TMPL_DIR}/log-viewer")
  set(MODEL "${ROOT_SOURCE_DIR}/model/${NAME}.mdl")

  if (NOT EXISTS ${MODEL})
    message(FATAL_ERROR "Model doesn't exist: ${MODEL}")
  endif ()

  if (p_VIEWER_NAME)
    set(VIEWER_NAME "${p_VIEWER_NAME}")
  else ()
    set(VIEWER_NAME "${PROJECT_NAME}-log-viewer")
  endif ()

  # Source directory
  if (p_SRC_DIR)
    set(SRC_DIR "${p_SRC_DIR}")
  else ()
    set(SRC_DIR "${ROOT_SOURCE_DIR}/src/common")
  endif ()
  if (NOT EXISTS ${SRC_DIR})
    file(MAKE_DIRECTORY "${SRC_DIR}")
  endif ()

  # Include directory
  if (p_INC_DIR)
    set(INC_DIR "${p_INC_DIR}")
  else ()
    set(INC_DIR "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}")
  endif ()
  if (NOT EXISTS ${INC_DIR})
    file(MAKE_DIRECTORY "${INC_DIR}")
  endif ()

  # Scripts directory
  if (p_SCT_DIR)
    set(SCT_DIR "${p_SCT_DIR}")
  else ()
    set(SCT_DIR "${CMAKE_BINARY_DIR}/scripts")
  endif ()
  if (NOT EXISTS ${SCT_DIR})
    file(MAKE_DIRECTORY "${SCT_DIR}")
  endif ()

  # Define custom commands to generate header/source/viewer files
  add_custom_command(
    OUTPUT ${INC_DIR}/${NAME}.hpp
    COMMAND ${VM} ${BASE}.hppct2 ${MODEL} ${INC_DIR}/${NAME}.hpp 0 102400
    WORKING_DIRECTORY ${INC_DIR}
    COMMENT "Generating ${INC_DIR}/${NAME}.hpp from ${MODEL}" VERBATIM
    DEPENDS ${VM} ${BASE}.hppct2 ${MODEL} 
    )

  add_custom_command(
    OUTPUT ${SRC_DIR}/${NAME}.cpp
    COMMAND ${VM} ${BASE}.cppct2 ${MODEL} ${SRC_DIR}/${NAME}.cpp 0 102400
    WORKING_DIRECTORY ${SRC_DIR}
    COMMENT "Generating ${SRC_DIR}/${NAME}.cpp from ${MODEL}" VERBATIM
    DEPENDS ${VM} ${BASE}.cppct2 ${MODEL} 
    )

  add_custom_command(
    OUTPUT ${SCT_DIR}/${VIEWER_NAME}.py
    COMMAND ${VM} ${VIEWER_BASE}.pyct2 ${MODEL} ${SCT_DIR}/${VIEWER_NAME}.py 0 102400
    COMMAND chmod 755 ${SCT_DIR}/${VIEWER_NAME}.py
    WORKING_DIRECTORY ${SCT_DIR}
    COMMENT "Generating ${SCT_DIR}/${VIEWER_NAME}.py from ${MODEL}" VERBATIM
    DEPENDS ${VM} ${VIEWER_BASE}.pyct2 ${MODEL} 
    )

  add_custom_target(
    ${VIEWER_NAME}
    DEPENDS ctpp2c ${SCT_DIR}/${VIEWER_NAME}.py
    )

  list(APPEND BOLTALOG_SOURCES "${INC_DIR}/${NAME}.hpp" "${SRC_DIR}/${NAME}.cpp")
  set(BOLTALOG_SOURCES "${BOLTALOG_SOURCES}" PARENT_SCOPE)

endfunction()
