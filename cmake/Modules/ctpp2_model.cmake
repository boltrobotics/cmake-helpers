include(ctpp2)

function (build_model model_path model_vm tmpl_name src_dir)
  cmake_parse_arguments(p "" "DEPS;SUFFIX" "" ${ARGN})

  if (NOT CT2_DIR)
    message(FATAL_ERROR "CT2_DIR is undefined")
  endif ()

  if (NOT TMPL_DIR)
    message(FATAL_ERROR "TMPL_DIR is undefined")
  endif ()

  if (NOT EXISTS ${CT2_DIR}})
    file(MAKE_DIRECTORY ${CT2_DIR})
  endif ()

  if (NOT EXISTS ${src_dir}})
    file(MAKE_DIRECTORY ${src_dir})
  endif ()

  get_filename_component(MODEL_NAME ${model_path} NAME_WE)
  set(MODEL_NAME "${MODEL_NAME}${p_SUFFIX}")

  set(HPPTMPL_PATH_SRC ${TMPL_DIR}/${tmpl_name}.hpptmpl)
  set(CPPTMPL_PATH_SRC ${TMPL_DIR}/${tmpl_name}.cpptmpl)
  set(HPPTMPL_PATH ${CMAKE_CURRENT_BINARY_DIR}/${tmpl_name}.hpptmpl)
  set(CPPTMPL_PATH ${CMAKE_CURRENT_BINARY_DIR}/${tmpl_name}.cpptmpl)
  set(HPPCT2_PATH ${CT2_DIR}/${MODEL_NAME}.hppct2)
  set(CPPCT2_PATH ${CT2_DIR}/${MODEL_NAME}.cppct2)
  set(HPP_PATH ${src_dir}/${MODEL_NAME}.hpp)
  set(CPP_PATH ${src_dir}/${MODEL_NAME}.cpp)

  # Need to replace year, include file name with the name of the model
  string(TIMESTAMP YEAR "%Y")
  configure_file(${HPPTMPL_PATH_SRC} ${HPPTMPL_PATH})
  configure_file(${CPPTMPL_PATH_SRC} ${CPPTMPL_PATH})

  add_custom_command(
    OUTPUT ${HPPCT2_PATH}
    COMMAND ${ctpp2_C} ${HPPTMPL_PATH} ${HPPCT2_PATH}
    WORKING_DIRECTORY ${CT2_DIR}
    COMMENT "Generating ${HPPCT2_PATH} from ${HPPTMPL_PATH}" VERBATIM
    DEPENDS ${HPPTMPL_PATH} ${p_DEPS}
    )

  add_custom_command(
    OUTPUT ${CPPCT2_PATH}
    COMMAND ${ctpp2_C} ${CPPTMPL_PATH} ${CPPCT2_PATH}
    WORKING_DIRECTORY ${CT2_DIR}
    COMMENT "Generating ${CPPCT2_PATH} from ${CPPTMPL_PATH}" VERBATIM
    DEPENDS ${CPPTMPL_PATH} ${p_DEPS}
    )

  add_custom_command(
    OUTPUT ${HPP_PATH}
    COMMAND ${model_vm} ${HPPCT2_PATH} ${model_path} ${HPP_PATH} 0 102400
    WORKING_DIRECTORY ${src_dir}
    COMMENT "Generating ${HPP_PATH} from ${model_path}" VERBATIM
    DEPENDS ${model_vm} ${HPPCT2_PATH} ${model_path} 
    )

  add_custom_command(
    OUTPUT ${CPP_PATH}
    COMMAND ${model_vm} ${CPPCT2_PATH} ${model_path} ${CPP_PATH} 0 102400
    WORKING_DIRECTORY ${src_dir}
    COMMENT "Generating ${CPP_PATH} from ${model_path}" VERBATIM
    DEPENDS ${model_vm} ${CPPCT2_PATH} ${model_path} 
    )

  if (NOT TARGET ${MODEL_NAME}-model)
    add_custom_target(
      ${MODEL_NAME}-model
      DEPENDS ctpp2_project ${HPP_PATH} ${CPP_PATH}
      )
  endif ()

endfunction ()
