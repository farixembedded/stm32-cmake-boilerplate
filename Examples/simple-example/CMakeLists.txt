# Copyright (c) 2021, Fractal Embedded LLC
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cmake_minimum_required(VERSION 3.13)

set(STM32_DISABLE_CPP_NEW ON)
include(../../cmake/stm32-boilerplate.cmake)
stm32_fetch_gcc_none_eabi()

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../stm32-cmake/cmake/stm32_gcc.cmake)

project(simple-example C CXX ASM)
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)


stm32_fetch_cmsis(G0)
stm32_fetch_hal(G0)

# import packages we'll be using
find_package(CMSIS COMPONENTS STM32G031K8T6U REQUIRED)
find_package(HAL COMPONENTS
    STM32G031K8T6U
    REQUIRED)

# enable C++ 17
set(CMAKE_CXX_STANDARD 17)

project(simple-example C CXX ASM)

add_executable(${PROJECT_NAME}
    main.c
    ${STM32_SOURCES}
)

add_binary_output(${PROJECT_NAME})


target_link_libraries(${PROJECT_NAME}
    CMSIS::STM32::G031K8
    STM32::Nano
)
