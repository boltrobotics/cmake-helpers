function(add_logger)
  cmake_parse_arguments(p "" "INC_DIR;SRC_DIR" "" ${ARGN})

  set(VM "boltalog-autogen")
  set(NAME logger)
  set(TMPL_DIR "$ENV{BOLTALOG_HOME}/template")
  set(BASE "${TMPL_DIR}/${NAME}")
  set(MODEL "${ROOT_SOURCE_DIR}/model/${NAME}.mdl")

  if (NOT EXISTS ${MODEL})
    message(FATAL_ERROR "Model doesn't exist: ${MODEL}")
  endif ()

  if (p_SRC_DIR)
    set(SRC_DIR "${p_SRC_DIR}")
  else ()
    set(SRC_DIR "${ROOT_SOURCE_DIR}/src/common")
  endif ()

  if (NOT EXISTS ${SRC_DIR})
    file(MAKE_DIRECTORY "${SRC_DIR}")
  endif ()

  if (p_INC_DIR)
    set(INC_DIR "${p_INC_DIR}")
  else ()
    set(INC_DIR "${ROOT_SOURCE_DIR}/include/${PROJECT_NAME}")
  endif ()

  if (NOT EXISTS ${INC_DIR})
    file(MAKE_DIRECTORY "${INC_DIR}")
  endif ()

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

  list(APPEND BOLTALOG_SOURCES "${INC_DIR}/${NAME}.hpp" "${SRC_DIR}/${NAME}.cpp")
  set(BOLTALOG_SOURCES "${BOLTALOG_SOURCES}" PARENT_SCOPE)

endfunction()
