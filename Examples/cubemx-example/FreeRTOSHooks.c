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

#include <FreeRTOS.h>
#include <task.h>
#include <timers.h>
// FreeRTOS has a number of hook functions that will be called by the OS if they are configured in.

void vApplicationTickHook(void) {}

void vApplicationIdleHook(void) {}

void vApplicationMallocFailedHook(void) {
	taskDISABLE_INTERRUPTS();
	for (;;)
		;
}

void vApplicationStackOverflowHook(TaskHandle_t pxTask, char* pcTaskName) {
	(void)pcTaskName;
	(void)pxTask;

	taskDISABLE_INTERRUPTS();
	for (;;)
		;
}

/* We use static allocation in FreeRTOS so we can keep a good handle on memory usage at compile
 * time. We ahve to provide the allocators for the idle and timer task memory resources.
 */
void vApplicationGetIdleTaskMemory(StaticTask_t** ppxIdleTaskTCBBuffer,
                                   StackType_t** ppxIdleTaskStackBuffer,
                                   uint32_t* pulIdleTaskStackSize) {
	static StackType_t IdleStack[configMINIMAL_STACK_SIZE];
	static StaticTask_t IdleTCB;

	*ppxIdleTaskTCBBuffer = &IdleTCB;
	*ppxIdleTaskStackBuffer = IdleStack;
	*pulIdleTaskStackSize = sizeof(IdleStack) / sizeof(IdleStack[0]);
}

void vApplicationGetTimerTaskMemory(StaticTask_t** ppxTimerTaskTCBBuffer,
                                    StackType_t** ppxTimerTaskStackBuffer,
                                    uint32_t* pulTimerTaskStackSize) {
	static StackType_t TimerStack[configTIMER_TASK_STACK_DEPTH];
	static StaticTask_t TimerTCB;

	*ppxTimerTaskTCBBuffer = &TimerTCB;
	*ppxTimerTaskStackBuffer = TimerStack;
	*pulTimerTaskStackSize = sizeof(TimerStack) / sizeof(TimerStack[0]);
}

// this is called by the generated CubeMX code. We can do any init we want to here.
// This is called after driver initialization but before the scheduler starts.
void MX_FREERTOS_Init(void) {}
