/*
 * Copyright (c) 2021, Fractal Embedded LLC
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// This file has fixes to the C++ implementation that take care of various issues on embedded
// systems.
#include <Stm32BoilerplateConfig.h>

// When any pure virtual methods are used in the program the compiler inserts a
// `__cxa_pure_virtual()` method. This method normally comes from libsupc++. The implementation
// there makes some calls to functions that will try and print that pull in reenteret newlib
// functions and creates an `_impure_ptr` structure for reentrancy tracking that takes up about 112
// bytes of memory.
// see: https://ecos-discuss.ecos.sourceware.narkive.com/ZD43gKSK/impure-ptr
//
// That implementation is defined weekly so we can override it here with our own to save memory.
// we just go into an infinite loop so we can trap that in a debugger.
#if defined(STM32_EMPTY_PURE_VIRTUAL_STUB)
extern "C" void __cxa_pure_virtual(void) {
	while (1)
		;
}
#endif