# STM32 Cmake Boilerplate

[![Tests](https://github.com/fractalembedded/stm32-cmake-boilerplate/actions/workflows/cmake.yaml/badge.svg)](https://github.com/fractalembedded/stm32-cmake-boilerplate/actions/workflows/cmake.yaml)

This repo adds additional source and CMake files to make creating embedded C and C++ projects for
the STM32. It is built on top of the [stm32-cmake](https://github.com/ObKo/stm32-cmake) proje

This project has currently been tested in the following conditions:
* Linux build host
* gnu++17 standard

## List of features
* Disable dynamic memory allocations at compile time in both C and C++
* Provide stubbed NewLib port syscalls for use with the nano environment
* Provide enhancements for C++ on embedded
  * C++ compiler options for smaller and more preformat code
  * Tweaks to GCC's C++ implementation to allow for no dynamic memory allocation and small code
    size.
* Examples showing inter-operation with STM32CubeMX
* VSCode integration examples for building and debugging.
* Permissively licensed under BSD-3 for personal or commercial use


## Quick Start Creation of New Project

TBD


## Examples
**simple-example**: Bare bones example

**blinky-example**: Blinking LED example with HAL drivers

**cubemx-exmaple**: CubeMX example wih FreeRTOS, C++, disabling dynamic memory allocations, custom
linker script for optimal RAM usage (minimal stack, no heap), STM32CubeG0 as a submodule.

## Detailed CMake configuration options

TBD


## STM32CubeMX integration

STM32CubeMX is a tool provided by STMicro for generating code and projects for the STM32 family.
It's use is not required, but some find it helpful for generating driver and clock config code.

The workflow for using it is as follows:
* Create a new CubeMX project for your target chip or devboard and go to the 'Project Manger' tab.
  * Set the project name to the same as your cmake project name with a `-cubemx` suffix. Example:
    `example-simple-cubemx`
  * Set 'Project Location' to the same folder as your `CMakeLists.txt` file
  * Set 'Toolchain / IDE' to 'Makefile'
  * Go to the 'Code Generator' tab on the left.
  * Set 'Add necessary library files as references in the toolchain project configuration file'
  * Set 'Generate peripheral initialization as a pari of .c/.h files per peripheral'
  * Save the project ang then generate the code. You can then check it into revision control.


## Target Loading and Debugging

TBD


## VSCode Integration

TBD


## Contributing Pull Requests

Pull Requests are welcome! If you heave a bugfix or improvement, feel free to open a PR. Just keep
things kind, constructive, and professional. Negative or exclusionary behavior will not be
tolerated.

Design considerations to keep in mind:
* All new features must be configurable from CMake with a sane default.
