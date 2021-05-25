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

include(${CMAKE_CURRENT_LIST_DIR}/default-build-type.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/fetch-gcc-arm.cmake)

### C++ dynamic allocation disable
option(STM32_DISABLE_CPP_NEW "Disable c++ new operator at compile time" OFF)
option(STM32_DISABLE_CPP_DELETE "Disable c++ delete operator at compile time" OFF)
if(STM32_DISABLE_CPP_NEW OR STM32_DISABLE_CPP_DELETE)
    list(APPEND STM32_SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/../Src/DynamicMemory/CppDynamicFixes.cpp
    )
endif()


### add the newlib syscalls to the code
list(APPEND STM32_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/../Src/SysCalls/SysCalls.c
)
include_directories(${CMAKE_CURRENT_BINARY_DIR})


### Set sane C++ settings for embedded
# Some compiler flags to make C++ more freiendly for embedded systems
# -fno-exceptions: Exceptions are non-deterministic and can cause dynamic allocations
# -fno-non-call-exceptions: C++ exceptions are not thrown from trapping instructions.
# -fno-rtti: RTTI can cause dynamic allocations and is very resource intensive
# -fno-use-cxa-atexit: Don't call gcc C style destructors at exit, we never exit
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-non-call-exceptions -fno-rtti -fno-use-cxa-atexit")

# Stub out the pure virtual handler on embedded platforms. This can reduce code size
option(STM32_EMPTY_PURE_VIRTUAL_STUB ON)
if(STM32_EMPTY_PURE_VIRTUAL_STUB)
list(APPEND STM32_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/../Src/CppFixes/CppFixes.cpp
)
endif()


### Set function sections and garbage collection during linking
# Put each function in it's own section and then have the linker run garbage collection
# This will safely prune unused code more throughly to reduce flash usage.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections")
set(CMAKE_LD_FLAGS "${CMAKE_LD_FLAGS} --gc-sections")

### setup the configure file
configure_file(${CMAKE_CURRENT_LIST_DIR}/../Src/Stm32BoilerplateConfig.h.in Stm32BoilerplateConfig.h)


### Set linker output for memory usage
# Add a map output and memory usage printing to the linker
# the size print output gives a nice percentage of ram and flash usage to keep an eye on
# the map file is useful for seeing exactly where ram and flash usage is going
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=output.map,--print-memory-usage")



### Force color output in diagnostics. If we ever go to CI we might wnat to detect that and turn off in those envrionments
# TODO: Give this an option
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fdiagnostics-color=always")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fdiagnostics-color=always")
set(CMAKE_LD_FLAGS "${CMAKE_LD_FLAGS} -fdiagnostics-color=always")

include_directories(${CMAKE_CURRENT_LIST_DIR}/../Src/FreeRTOS/)
# # set(STM32_CUBE_G0_PATH ../${CMAKE_CURRENT_SOURCE_DIR}/STM32CubeG0/)
# # set(FREERTOS_PATH ${STM32_CUBE_G0_PATH}/Middlewares/Third_Party/FreeRTOS/)

# if (DEFINED STM32_CUBEMX_PATH)
#     list(APPEND STM32_BOILERPLATE_SOURCES
#         ${STM32_CUBEMX_PATH}/Core/Src/main.c
#         ${STM32_CUBEMX_PATH}/Core/Src/stm32g0xx_hal_msp.c
#         ${STM32_CUBEMX_PATH}/Core/Src/stm32g0xx_it.c
#         ${STM32_CUBEMX_PATH}/Core/Src/system_stm32g0xx.c
#     )
# endif()

# add_library(
#     # Library name
#     stm32_boilerplate
#     STATIC
#     ${STM32_BOILERPLATE_SOURCES}
# )

# target_include_directories(stm32_boilerplate
#     PUBLIC
#     ${STM32_CUBEMX_PATH}/Core/Inc/
# )



# #     rt-micro-cubemx/Core/Inc/

# #     # Application includes
# #     Src/
# # )


# # project(rt-micro C CXX ASM)
# # # enable C++ 17
# # set(CMAKE_CXX_STANDARD 17)

# # # import packages we'll be using
# # find_package(CMSIS COMPONENTS STM32G031K8T6U REQUIRED)
# # find_package(HAL COMPONENTS STM32G031K8T6U REQUIRED)
# # find_package(FreeRTOS COMPONENTS ARM_CM0 REQUIRED)

# # set(PROJECT_SOURCES
# #     Src/Tasks/BlinkyTask.cpp

# #     Src/SystemConfig/FreeRTOSHooks.c
# #     Src/SystemConfig/MainSetupHook.c
# #     Src/SystemConfig/SysCalls.c

# #     rt-micro-cubemx/Core/Src/main.c
# #     rt-micro-cubemx/Core/Src/gpio.c
# #     rt-micro-cubemx/Core/Src/usart.c
# #     rt-micro-cubemx/Core/Src/stm32g0xx_hal_timebase_tim.c
# #     rt-micro-cubemx/Core/Src/stm32g0xx_it.c
# # )

# # add_executable(rt-micro ${PROJECT_SOURCES})

# # # We use a custom linker script so we can tune the stack and heap
# # stm32_add_linker_script(rt-micro
# #     PRIVATE
# #     rt-micro.ld
# # )

# # target_compile_definitions(rt-micro PRIVATE USE_HAL_DRIVER)

# # target_include_directories(rt-micro
# #     PRIVATE
# #     rt-micro-cubemx/Core/Inc/

# #     # Application includes
# #     Src/
# # )

# target_link_libraries(rt-micro
#     FreeRTOS::Timers
#     FreeRTOS::Heap::1
#     FreeRTOS::ARM_CM0
#     HAL::STM32::G0::GPIO
#     HAL::STM32::G0::UARTEx
#     HAL::STM32::G0::TIMEx
#     HAL::STM32::G0::RCCEx
#     HAL::STM32::G0::PWREx
#     HAL::STM32::G0::CORTEX
#     # Note: use the family, not device so we don't get a generated linker script
#     CMSIS::STM32::G031xx
#     STM32::Nano
# )

# # we patch a few vendor headers in the system start folder. We need to put it at
# # front of the line so it can take precidence.
# target_include_directories(rt-micro
#     BEFORE PRIVATE
#     Src/SystemConfig
# )

# # Force color output in diagnostics. If we ever go to CI we might wnat to detect that and turn off in those envrionments
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fdiagnostics-color=always")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fdiagnostics-color=always")
# set(CMAKE_LD_FLAGS "${CMAKE_CXX_FLAGS} -fdiagnostics-color=always")

# # Some settings to make C++ more freiendly for embedded systems
# # -fno-exceptions: Exceptions are non-deterministic and can cause dynamic allocations
# # -fno-non-call-exceptions: C++ exceptions are not thrown from trapping instructions.
# # -fno-rtti: RTTI can cause dynamic allocations and is very resource intensive
# # -fno-use-cxa-atexit: Don't call gcc C style destructors at exit, we never exit
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-non-call-exceptions -fno-rtti -fno-use-cxa-atexit")

# # Put each function in it's own section and then have the linker run garbage collection
# # This will safely prune unused code more throughly to reduce flash usage.
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections -fdata-sections")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections")
# set(CMAKE_LD_FLAGS "${CMAKE_LD_FLAGS} --gc-sections")

# # generate stack useage information
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstack-usage -fcallgraph-info")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-usage -fcallgraph-info")

# # The following lines enable link time optimizaions. This causes issues with static stack analysis.
# # set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -flto")
# # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto")
# # set(CMAKE_LD_FLAGS "${CMAKE_CXX_FLAGS} -flto")

# # Add a map output and memory usage printing to the linker
# # the size print output gives a nice percentage of ram and flash usage to keep an eye on
# # the map file is useful for seeing exactly where ram and flash usage is going
# set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=output.map,--print-memory-usage")
