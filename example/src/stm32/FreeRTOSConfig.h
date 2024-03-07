/*
 * FreeRTOS Kernel <DEVELOPMENT BRANCH>
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/*******************************************************************************
 * This file provides an example FreeRTOSConfig.h header file, inclusive of an
 * abbreviated explanation of each configuration item.  Online and reference
 * documentation provides more information.
 * https://www.freertos.org/a00110.html
 *
 * Constant values enclosed in square brackets ('[' and ']') must be completed
 * before this file will build.
 *
 * Use the FreeRTOSConfig.h supplied with the RTOS port in use rather than this
 * generic file, if one is available.
 ******************************************************************************/

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#define configCPU_CLOCK_HZ                        ((unsigned long) 72000000)
#define configSYSTICK_CLOCK_HZ                    (configCPU_CLOCK_HZ / 8) // vTaskDelay() fix

#define configTICK_RATE_HZ                        ((TickType_t) 250)  // See book
#define configUSE_PREEMPTION                      1
#define configUSE_TIME_SLICING                    0
#define configUSE_TICKLESS_IDLE                   0
#define configMAX_PRIORITIES                      5
#define configMINIMAL_STACK_SIZE                  ((unsigned short) 128)
#define configMAX_TASK_NAME_LEN                   16
// Only configTICK_TYPE_WIDTH_IN_BITS or configUSE_16_BIT_TICKS must be used
//#define configTICK_TYPE_WIDTH_IN_BITS             TICK_TYPE_WIDTH_64_BITS
#define configUSE_16_BIT_TICKS                    0
#define configIDLE_SHOULD_YIELD                   1
#define configTASK_NOTIFICATION_ARRAY_ENTRIES     1
#define configQUEUE_REGISTRY_SIZE                 0
#define configENABLE_BACKWARD_COMPATIBILITY       0
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS   0
#define configUSE_MINI_LIST_ITEM                  1
#define configSTACK_DEPTH_TYPE                    size_t
#define configMESSAGE_BUFFER_LENGTH_TYPE          size_t
#define configHEAP_CLEAR_MEMORY_ON_FREE           1
#define configSTATS_BUFFER_MAX_LENGTH             0xFFFF
#define configUSE_NEWLIB_REENTRANT                0
#define configUSE_TIMERS                          1
#define configTIMER_TASK_PRIORITY                 ( configMAX_PRIORITIES - 1 )
#define configTIMER_TASK_STACK_DEPTH              configMINIMAL_STACK_SIZE
#define configTIMER_QUEUE_LENGTH                  10
#define configSUPPORT_STATIC_ALLOCATION           1
#define configSUPPORT_DYNAMIC_ALLOCATION          1
#define configTOTAL_HEAP_SIZE                     ((size_t)( 17 * 1024 ))
#define configAPPLICATION_ALLOCATED_HEAP          0
#define configSTACK_ALLOCATION_FROM_SEPARATE_HEAP 0
#define configENABLE_HEAP_PROTECTOR               0

/* This is the raw value as per Cortex-M3 NVIC. Values can be 255 (lowest) to 0 (1?) (highest). */
#define configKERNEL_INTERRUPT_PRIORITY           255
/* This is the value being used as per the ST library which permits 16 priority values, 0 to 15.
 * This must correspond to the configKERNEL_INTERRUPT_PRIORITY setting. Here 15 corresponds to
 * the lowest NVIC value of 255. */
#define configLIBRARY_KERNEL_INTERRUPT_PRIORITY   15
/* This must not be set to zero! See http://www.FreeRTOS.org/RTOS-Cortex-M3-M4.html. */
#define configMAX_SYSCALL_INTERRUPT_PRIORITY      191 // equivalent to 0xb0, or priority 11.
/* Another name for configMAX_SYSCALL_INTERRUPT_PRIORITY - the name used depends
 * on the FreeRTOS port. */
#define configMAX_API_CALL_INTERRUPT_PRIORITY     191

#define configUSE_IDLE_HOOK                       0
#define configUSE_TICK_HOOK                       0
#define configUSE_MALLOC_FAILED_HOOK              0
#define configUSE_DAEMON_TASK_STARTUP_HOOK        0
#define configUSE_SB_COMPLETED_CALLBACK           0
#define configCHECK_FOR_STACK_OVERFLOW            1 // See book
#define configGENERATE_RUN_TIME_STATS             0
#define configUSE_TRACE_FACILITY                  0
#define configUSE_STATS_FORMATTING_FUNCTIONS      0
#define configUSE_CO_ROUTINES                     0
#define configMAX_CO_ROUTINE_PRIORITIES           2

#define configASSERT( x )         \
    if( ( x ) == 0 )              \
    {                             \
        taskDISABLE_INTERRUPTS(); \
        for( ; ; )                \
        ;                         \
    }

#define configINCLUDE_APPLICATION_DEFINED_PRIVILEGED_FUNCTIONS    0
#define configTOTAL_MPU_REGIONS                                   8
#define configTEX_S_C_B_FLASH                                     0x07UL
#define configTEX_S_C_B_SRAM                                      0x07UL
#define configENFORCE_SYSTEM_CALLS_FROM_KERNEL_ONLY               1
#define configALLOW_UNPRIVILEGED_CRITICAL_SECTIONS                0
#define configUSE_MPU_WRAPPERS_V1                                 0
#define configPROTECTED_KERNEL_OBJECT_POOL_SIZE                   10
#define configSYSTEM_CALL_STACK_SIZE                              128
#define configENABLE_ACCESS_CONTROL_LIST                          1

#define configRUN_MULTIPLE_PRIORITIES             0
#define configUSE_CORE_AFFINITY                   0
#define configTASK_DEFAULT_CORE_AFFINITY          tskNO_AFFINITY
#define configUSE_TASK_PREEMPTION_DISABLE         0
#define configUSE_PASSIVE_IDLE_HOOK               0
#define configTIMER_SERVICE_TASK_CORE_AFFINITY    tskNO_AFFINITY

#define secureconfigMAX_SECURE_CONTEXTS           5
#define configKERNEL_PROVIDED_STATIC_MEMORY       1

#define configENABLE_TRUSTZONE                    1
#define configRUN_FREERTOS_SECURE_ONLY            1
#define configENABLE_MPU                          1
#define configENABLE_FPU                          1
#define configENABLE_MVE                          1

#define configUSE_TASK_NOTIFICATIONS              1
#define configUSE_MUTEXES                         0
#define configUSE_RECURSIVE_MUTEXES               0
#define configUSE_COUNTING_SEMAPHORES             0
#define configUSE_QUEUE_SETS                      0
#define configUSE_APPLICATION_TASK_TAG            0

// Set the following definitions to 1 to include the API function, or zero to exclude the
// API function.
#define INCLUDE_vTaskPrioritySet                  0
#define INCLUDE_uxTaskPriorityGet                 0
#define INCLUDE_vTaskDelete                       0
#define INCLUDE_vTaskSuspend                      0
#define INCLUDE_xResumeFromISR                    1
#define INCLUDE_vTaskDelayUntil                   0
#define INCLUDE_vTaskDelay                        1
#define INCLUDE_xTaskGetSchedulerState            0
#define INCLUDE_xTaskGetCurrentTaskHandle         1
#define INCLUDE_uxTaskGetStackHighWaterMark       0
#define INCLUDE_xTaskGetIdleTaskHandle            0
#define INCLUDE_eTaskGetState                     0
#define INCLUDE_xEventGroupSetBitFromISR          1
#define INCLUDE_xTimerPendFunctionCall            0
#define INCLUDE_xTaskAbortDelay                   0
#define INCLUDE_xTaskGetHandle                    0
#define INCLUDE_xTaskResumeFromISR                1

/* These are not in generic FreeRTOSConfig */

#define configUSE_ALTERNATIVE_API                 0
#define INCLUDE_vTaskCleanUpResources             0

// UART configuration.
#define configCOM0_RX_BUFFER_LENGTH               128
#define configCOM0_TX_BUFFER_LENGTH               128
#define configCOM1_RX_BUFFER_LENGTH               128
#define configCOM1_TX_BUFFER_LENGTH               128

#endif /* FREERTOS_CONFIG_H */
