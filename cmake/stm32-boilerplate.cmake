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

### Dynamic allocation setup
# Master option for no dynamic all all
option(STM32_NO_DYNAMIC_ALLOCATION "Disable all dynamic allocation at compiler time by default (can be overridden individually)" OFF)

# C++ dynamic allocation disable
option(STM32_DISABLE_CPP_NEW "Disable c++ new operator at compile time" ${STM32_NO_DYNAMIC_ALLOCATION})
option(STM32_DISABLE_CPP_DELETE "Disable c++ delete operator at compile time" ${STM32_NO_DYNAMIC_ALLOCATION})
if(STM32_DISABLE_CPP_NEW OR STM32_DISABLE_CPP_DELETE)
    list(APPEND STM32_SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/../Src/DynamicMemory/CppDynamicFixes.cpp
    )
endif()

# C malloc/free dynamic allocation
option(STM32_DISABLE_C_MALLOC "Disable C malloc with compile time error" ${STM32_NO_DYNAMIC_ALLOCATION})
option(STM32_DISABLE_C_FREE "Disable C free with compile time error" ${STM32_NO_DYNAMIC_ALLOCATION})
option(STM32_DISABLE_C_REALLOC "Disable C realloc with compile time error" ${STM32_NO_DYNAMIC_ALLOCATION})
option(STM32_DISABLE_C_CALLOC "Disable C calloc with compile time error" ${STM32_NO_DYNAMIC_ALLOCATION})
if(STM32_DISABLE_C_MALLOC OR STM32_DISABLE_C_FREE OR STM32_DISABLE_C_REALLOC OR STM32_DISABLE_C_CALLOC)
    list(APPEND STM32_SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/../Src/DynamicMemory/MallocFixes.c
    )
    if(STM32_DISABLE_C_MALLOC)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--wrap=malloc")
    endif()
    if(STM32_DISABLE_C_FREE)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--wrap=free")
    endif()
    if(STM32_DISABLE_C_REALLOC)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--wrap=realloc")
    endif()
    if(STM32_DISABLE_C_CALLOC)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--wrap=calloc")
    endif()
endif()


### add the newlib syscalls to the code
option(STM32_INCLUDE_NEWLIB_PORT_STUBS "Include stubs for all newlib port calls" ON)
if(STM32_INCLUDE_NEWLIB_PORT_STUBS)
    list(APPEND STM32_SOURCES
        ${CMAKE_CURRENT_LIST_DIR}/../Src/SysCalls/SysCalls.c
    )
endif()


### Set sane C++ settings for embedded
# Some compiler flags to make C++ more freiendly for embedded systems
# -fno-exceptions: Exceptions are non-deterministic and can cause dynamic allocations
# -fno-non-call-exceptions: C++ exceptions are not thrown from trapping instructions.
# -fno-rtti: RTTI can cause dynamic allocations and is very resource intensive
# -fno-use-cxa-atexit: Don't call gcc C style destructors at exit, we never exit
option(STM32_USE_EMBEDDED_CXX_FLAGS "Use vairous C++ flags for embedded (no RTTI, exceptions, etc.)" ON)
if(STM32_USE_EMBEDDED_CXX_FLAGS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-non-call-exceptions -fno-rtti -fno-use-cxa-atexit")
endif()

# Stub out the pure virtual handler on embedded platforms. This can reduce code size
option(STM32_EMPTY_PURE_VIRTUAL_STUB "Define a stub for g++'s run-time pure virtual call to reduce code size" ON)
if(STM32_EMPTY_PURE_VIRTUAL_STUB)
list(APPEND STM32_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/../Src/CppFixes/CppFixes.cpp
)
endif()


### Set up compiler errors and warnings to be fairly strict
option(STM32_USE_AGRESSIVE_COMPILER_ERRORS "Turn on fairly agressive compiler errors" ON)
if(STM32_USE_AGRESSIVE_COMPILER_ERRORS)
    set(STM32_COMMON_FLAGS "-Wall -Wno-strict-aliasing -Wno-unused-local-typedefs -Wno-deprecated-declarations -Wno-multichar -Werror")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${STM32_COMMON_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${STM32_COMMON_FLAGS} -Werror=suggest-override")
endif()


### Set function sections and garbage collection during linking
# Put each function in it's own section and then have the linker run garbage collection
# This will safely prune unused code more throughly to reduce flash usage.
option(STM32_USE_FUNCTION_SECTION "Use function sections and garbage collecion to reduce code size" ON)
if(STM32_USE_FUNCTION_SECTION)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections -fdata-sections")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffunction-sections -fdata-sections")
    set(CMAKE_LD_FLAGS "${CMAKE_LD_FLAGS} --gc-sections")
endif()


## Generate stack usage info
option(STM32_GENERATE_STACK_USAGE "Generate stack usage and call graph for static stack analysis" ON)
if(STM32_GENERATE_STACK_USAGE)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstack-usage -fcallgraph-info")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-usage -fcallgraph-info")
endif()

 # The following lines enable link time optimizaions. This causes issues with static stack analysis.
## Link time optimizaion
option(STM32_ENABLE_LTO "Turn on link time optimizaions" OFF)
if(STM32_ENABLE_LTO)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -flto")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -flto")
    set(CMAKE_LD_FLAGS "${CMAKE_CXX_FLAGS} -flto")
endif()

# Check if LTO amd stack usage are on together
if(STM32_ENABLE_LTO AND STM32_GENERATE_STACK_USAGE)
    message(FATAL_ERROR "LTO and stack usage cannot be enabled together.")
endif()


### Set linker output for memory usage
# Add a map output and memory usage printing to the linker
# the size print output gives a nice percentage of ram and flash usage to keep an eye on
# the map file is useful for seeing exactly where ram and flash usage is going
option(STM32_GENERTE_MAP_AND_MEM_USAGE "Genearte a linker map file and print memory usage" ON)
if(STM32_GENERTE_MAP_AND_MEM_USAGE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=output.map,--print-memory-usage")
endif()


### Force color output in diagnostics. If we ever go to CI we might wnat to detect that and turn off in those envrionments
# TODO: Give this an option
option(STM32_FORCE_GCC_COLOR_OUTPUT "Force GCC to do color output" ON)
if(STM32_FORCE_GCC_COLOR_OUTPUT)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fdiagnostics-color=always")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fdiagnostics-color=always")
    set(CMAKE_LD_FLAGS "${CMAKE_LD_FLAGS} -fdiagnostics-color=always")
endif()


### FreeRTOS related
# Enable RTOS CMSIS stubs that allow you to use CubeMX generated FreeRTOS without full CMSIS
# This is useful if you want to use CubeMX to generate FreeRTOS code, but you don't want the full overhead of CMSIS.
# option(STM32_FORCE_GCC_COLOR_OUTPUT "Force GCC to do color output" ON)
option(STM32_FREERTOS_CMSIS_STUBS "Enable FreeRTOS CMSIS stubs" OFF)
if(STM32_FREERTOS_CMSIS_STUBS)
    # Add local FreeRTOS dir to search path so things compile
    include_directories(${CMAKE_CURRENT_LIST_DIR}/../Src/FreeRTOS/)
endif()


### generate the configure file
# Do this last so we get all the settings correct
configure_file(${CMAKE_CURRENT_LIST_DIR}/../Src/Stm32BoilerplateConfig.h.in config_output/Stm32BoilerplateConfig.h)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/config_output)


### Generate hex and bin outputs
# Helper function for making binary output
function(add_binary_output TARGET)
    add_custom_command(TARGET ${TARGET}
            POST_BUILD
            COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
            COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin)
endfunction()

