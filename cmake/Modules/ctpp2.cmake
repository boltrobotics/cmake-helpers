set(CTPP2_HOME $ENV{CTPP2_HOME})

if (NOT CTPP2_HOME)
  message(FATAL_ERROR "CTPP2_HOME undefined")
endif ()

include(ExternalProject)

ExternalProject_Add(
  ctpp2_project
  PREFIX        ${CTPP2_HOME}/build-x86/${CMAKE_BUILD_TYPE}
  DOWNLOAD_DIR  ${CTPP2_HOME}
  SOURCE_DIR    ${CTPP2_HOME}
  BINARY_DIR    ${CTPP2_HOME}/build-x86/${CMAKE_BUILD_TYPE}/work
  CMAKE_ARGS    -DCMAKE_INSTALL_PREFIX:PATH=${CTPP2_HOME}/build-x86/${CMAKE_BUILD_TYPE}
)

ExternalProject_Get_Property(ctpp2_project INSTALL_DIR)
set(ctpp2_BIN_DIR ${INSTALL_DIR}/bin)
set(ctpp2_C ${INSTALL_DIR}/bin/ctpp2c)
set(ctpp2_C ${INSTALL_DIR}/bin/ctpp2c)
set(ctpp2_INC_DIR ${INSTALL_DIR}/include/ctpp2)
set(ctpp2_LIB ${INSTALL_DIR}/lib/libctpp2.so)
