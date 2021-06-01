Fix x86 build
- Added gtest_INC/LIB variable for when system gtest is used
- Removed references/files to Arduino set-up
- Cleaned up redundant statements like BTR_X86 in main_project, it's set in init.cmake. Same for
  BOARD_FAMILY
- Moved find_test_srcs from init.cmake to test_project.cmake
- Moved definitions from unit_testing.cmake to main_project.cmake. Deleted unit_testing
- Added -t switch to make.sh to avoid specifying -DENABLE_TESTS=ON on command line
