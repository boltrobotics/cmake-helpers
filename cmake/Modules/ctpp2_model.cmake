include(ctpp2)

function (build_model model_path model_vm tmpl_name src_dir)
  cmake_parse_arguments(p "" "DEPS" "" ${ARGN})

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

  set(HPPTMPL_PATH ${TMPL_DIR}/${tmpl_name}.hpptmpl)
  set(CPPTMPL_PATH ${TMPL_DIR}/${tmpl_name}.cpptmpl)
  set(HPPCT2_PATH ${CT2_DIR}/${tmpl_name}.hppct2)
  set(CPPCT2_PATH ${CT2_DIR}/${tmpl_name}.cppct2)
  set(HPP_PATH ${src_dir}/${tmpl_name}.hpp)
  set(CPP_PATH ${src_dir}/${tmpl_name}.cpp)

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

  # Executable, library, or other target would add dependency on ${tmpl_name}-tmpl
  #
  add_custom_target(${tmpl_name}-tmpl
    DEPENDS ctpp2_project ${HPP_PATH} ${CPP_PATH}
    )

endfunction ()
