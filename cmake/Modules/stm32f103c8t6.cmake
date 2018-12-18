# Sets "-Og -g". Disable it as "-Og" level causes BluePill to lock up for unknown reason.
unset(CMAKE_C_FLAGS_DEBUG)
unset(CMAKE_CXX_FLAGS_DEBUG)
# Sets "-Os -flto" when CMAKE_BUILD_TYPE=Release, but causes symbol vTaskSwitchContext disappear
unset(CMAKE_C_FLAGS_RELEASE)
unset(CMAKE_CXX_FLAGS_RELEASE)

function(print_compile_flags)
  message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")
  message(STATUS "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}")
  message(STATUS "CMAKE_C_FLAGS_DEBUG: ${CMAKE_C_FLAGS_DEBUG}")
  message(STATUS "CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
  message(STATUS "CMAKE_C_FLAGS_RELEASE: ${CMAKE_C_FLAGS_RELEASE}")
  message(STATUS "CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")
  message(STATUS "CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}")
  message(STATUS "CMAKE_MODULE_LINKER_FLAGS: ${CMAKE_MODULE_LINKER_FLAGS}")
  message(STATUS "CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}")
  message(STATUS "CMAKE_STATIC_LINKER_FLAGS: ${CMAKE_STATIC_LINKER_FLAGS}")
endfunction()

set(O_FLAGS "-Os -g")
set(M_FLAGS "-mthumb -mcpu=cortex-m3 -mabi=aapcs -msoft-float -MD")
set(F_FLAGS "-fno-builtin -ffunction-sections -fdata-sections -fno-common -fomit-frame-pointer")
set(F_FLAGS "${F_FLAGS} -fno-unroll-loops -ffast-math -ftree-vectorize -fno-exceptions")
set(F_FLAGS "${F_FLAGS} -fno-unwind-tables")
set(W_FLAGS "-Wall -Wextra -Wshadow -Wredundant-decls -Wundef")

#set(CMAKE_C_FLAGS "${O_FLAGS} ${M_FLAGS} ${F_FLAGS} ${W_FLAGS}")
set(CMAKE_CXX_FLAGS "${O_FLAGS} ${M_FLAGS} ${F_FLAGS} ${W_FLAGS}")

# From book: -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group")
set(LD_FLAGS "--static -nostartfiles -specs=nosys.specs")
set(LD_FLAGS "${LD_FLAGS} -Wl,-Map=${PROJECT_NAME}.map -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${M_FLAGS} ${LD_FLAGS}")
