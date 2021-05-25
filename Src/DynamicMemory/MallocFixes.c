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

#include <stddef.h>
#include <Stm32BoilerplateConfig.h>

void* you_used_a_dynamic_allocation_dont_do_that();
void you_used_a_dynamic_deallocation_dont_do_that();

/* We use -Wl,--wrap=malloc,--wrap=free,--wrap=realloc,--wrap=calloc to the linker so we can wrap
 * the toolchain provided versions of malloc and free. In this case we just put an undefined
 * function to raise an error, but in the future we could be more granular about this like allow
 * allocations during system startup only and then disabling them at runtime with a variable flag.
 */
#if defined(STM32_DISABLE_C_MALLOC)
// you can use the `__read_FUNCTION` pattern to call the original function
// void* __real_malloc(size_t);
void* __wrap_malloc(size_t bytes) {
	return you_used_a_dynamic_allocation_dont_do_that();
	// to call original malloc
	// return __real_malloc(bytes);
}
#endif

#if defined(STM32_DISABLE_C_FREE)
void __wrap_free(void* addr) {
	you_used_a_dynamic_deallocation_dont_do_that();
}
#endif

#if defined(STM32_DISABLE_C_REALLOC)
void* __wrap_realloc(void* addr) {
	return you_used_a_dynamic_allocation_dont_do_that();
}
#endif

#if defined(STM32_DISABLE_C_CALLOC)
void* __wrap_calloc(size_t num, size_t size) {
	return you_used_a_dynamic_allocation_dont_do_that();
}
#endif
