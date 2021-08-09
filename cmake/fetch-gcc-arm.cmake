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

# We fetch the offical arm-none-eabi tool chain as part of the cmake build
# this makes this file the sole point of truth for what version of GCC to use for both devlopment and CI builds

include(FetchContent)

FetchContent_Declare(
    arm-none-eabi
    URL      https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
    #URL       file:///home/mcampbell/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
    #URL_HASH MD5=8312c4c91799885f222f663fc81f9a31
    #SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/gcc-arm-none-eabi
)

function(stm32_fetch_gcc_none_eabi)
    # Allow env var to act as a backup to one set in CMake
    if(NOT DEFINED STM32_TOOLCHAIN_PATH AND DEFINED ENV{STM32_TOOLCHAIN_PATH})
        # Set in both local and parent scope
        set(STM32_TOOLCHAIN_PATH "$ENV{STM32_TOOLCHAIN_PATH}")
        set(STM32_TOOLCHAIN_PATH "${STM32_TOOLCHAIN_PATH}" PARENT_SCOPE)
        message(STATUS "Setting gcc path from envrionment var")
    endif()

    if(DEFINED STM32_TOOLCHAIN_PATH)
        message(STATUS "skipping gcc fetch, STM32_TOOLCHAIN_PATH set to: ${STM32_TOOLCHAIN_PATH}")
        return()
    endif()

    FetchContent_GetProperties(arm-none-eabi POPULATED GCC_POPULATED)
    if(NOT GCC_POPULATED)
        set(FETCHCONTENT_QUIET FALSE) # To see progress
        FetchContent_Populate(arm-none-eabi)
    else()
        return()
    endif()

    # set the varible for the toolchain path for stm32-cmake
    FetchContent_GetProperties(arm-none-eabi SOURCE_DIR GCC_PATH)
    set(STM32_TOOLCHAIN_PATH ${GCC_PATH} PARENT_SCOPE)
endfunction()
