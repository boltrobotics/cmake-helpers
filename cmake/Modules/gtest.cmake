include(project_setup)

find_package(Boost REQUIRED COMPONENTS system thread)
find_package(GTest)

if (GTEST_FOUND)
  include_directories(${GTEST_INCLUDE_DIRS})
else ()
  set(GTEST_HOME $ENV{GTEST_HOME})

  if (NOT GTEST_HOME)
    set(GTEST_HOME "${CMAKE_BINARY_DIR}/gtest")
  endif ()

  # Prevent overriding the parent project's compiler/linker settings on Windows
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  option(BUILD_GMOCK OFF)
  option(INSTALL_GTEST OFF)

  add_project(
    PREFIX gtest
    URL "https://github.com/google/googletest.git"
    HOME "${GTEST_HOME}"
    INC_DIR "${GTEST_HOME}/googletest/include")

  if (TARGET gtest)
    set_target_properties(gtest
      PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${OUTPUT_PATH}/bin"
      LIBRARY_OUTPUT_DIRECTORY "${OUTPUT_PATH}/lib"
      ARCHIVE_OUTPUT_DIRECTORY "${OUTPUT_PATH}/lib"
      PDB_OUTPUT_DIRECTORY "${OUTPUT_PATH}/bin")
  endif ()
  if (TARGET gtest_main)
    set_target_properties(gtest_main
      PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${OUTPUT_PATH}/bin"
      LIBRARY_OUTPUT_DIRECTORY "${OUTPUT_PATH}/lib"
      ARCHIVE_OUTPUT_DIRECTORY "${OUTPUT_PATH}/lib"
      PDB_OUTPUT_DIRECTORY "${OUTPUT_PATH}/bin")
  endif ()
endif ()
