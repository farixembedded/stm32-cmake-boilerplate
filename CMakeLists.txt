cmake_minimum_required(VERSION 3.13)

include(cmake/stm32-boilerplate.cmake)
stm32_fetch_gcc_none_eabi()

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/stm32-cmake/cmake/stm32_gcc.cmake)

project(stm32-cmake-boilerplate)
add_subdirectory(Examples/blinky-example)
add_subdirectory(Examples/simple-example)
