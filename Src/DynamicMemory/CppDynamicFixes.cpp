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

/* This file holds replacements for dynamic allocation operators and functions to make them link
 * time issues. This makes it obvious if we accidentally bring in dynamic allocation into our
 * embedded system. Based on: https://www.embedded.com/preventing-dynamic-allocation/
 */
#include <Stm32BoilerplateConfig.h>
#include <new>

// these are intentionally not defined anywhere to force a linker error if any new/delete operators
// are used
void* you_used_a_dynamic_allocation_dont_do_that();
void you_used_a_dynamic_deallocation_dont_do_that();

#if defined(STM32_DISABLE_CPP_NEW)
#define REPLACE_NEW(PROTOTYPE)                                                                     \
	void* operator new PROTOTYPE { return you_used_a_dynamic_allocation_dont_do_that(); }
REPLACE_NEW((std::size_t))
REPLACE_NEW([](std::size_t))
REPLACE_NEW((std::size_t, std::align_val_t))
REPLACE_NEW([](std::size_t, std::align_val_t))
REPLACE_NEW((std::size_t, const std::nothrow_t&))
REPLACE_NEW([](std::size_t, const std::nothrow_t&))
REPLACE_NEW((std::size_t, std::align_val_t, const std::nothrow_t&))
REPLACE_NEW([](std::size_t, std::align_val_t, const std::nothrow_t&))
#endif

#if defined(STM32_DISABLE_CPP_DELETE)
#define REPLACE_DELETE(PROTOTYPE)                                                                  \
	void operator delete PROTOTYPE { you_used_a_dynamic_deallocation_dont_do_that(); }
REPLACE_DELETE((void*))
REPLACE_DELETE([](void*))
REPLACE_DELETE((void*, std::align_val_t))
REPLACE_DELETE([](void*, std::align_val_t))
REPLACE_DELETE((void*, std::size_t))
REPLACE_DELETE([](void*, std::size_t))
REPLACE_DELETE((void*, std::size_t, std::align_val_t))
REPLACE_DELETE([](void*, std::size_t, std::align_val_t))
REPLACE_DELETE((void*, const std::nothrow_t&))
REPLACE_DELETE([](void*, const std::nothrow_t&))
REPLACE_DELETE((void*, std::align_val_t, const std::nothrow_t&))
REPLACE_DELETE([](void*, std::align_val_t, const std::nothrow_t&))
#endif
