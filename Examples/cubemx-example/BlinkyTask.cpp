// Copyright (c) 2021 Fractal Embedded LLC. All rights reserved.
#include "main.h" // STM generated header to get access to board defintitions and drivers
#include <stdlib.h>
#include <FreeRTOS.h>
#include <task.h>


namespace {
    constexpr int STACK_SIZE_WORDS = 40;

	class BlinkyTask {
	public:
		BlinkyTask() : m_taskHandle(xTaskCreateStatic(taskRunner,
                                "blinky",
                                STACK_SIZE_WORDS,
                                this,
                                tskIDLE_PRIORITY,
                                m_stack,
                                &m_TCB)) {}

	private:
        static void taskRunner(void* context);
		void run();

		StackType_t m_stack[STACK_SIZE_WORDS];
		StaticTask_t m_TCB;
		TaskHandle_t m_taskHandle;
	};

	BlinkyTask blinkyTask;
}

void BlinkyTask::taskRunner(void* context) {
    BlinkyTask* task = static_cast<BlinkyTask*>(context);
    task->run();
}

void BlinkyTask::run() {
	while (1) {
		vTaskDelay(100);
		HAL_GPIO_TogglePin(LD3_GPIO_Port, LD3_Pin);
	}
}
