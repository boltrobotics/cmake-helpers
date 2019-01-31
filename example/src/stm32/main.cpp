// Copyright (C) 2019 Bolt Robotics <info@boltrobotics.com>
// License: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

// SYSTEM INCLUDES
#include "FreeRTOS.h"
#include "task.h"
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/gpio.h>

// PROJECT INCLUDES
#include "example.hpp"

// For built-in LED in BlackPill use GPIOB, GPIO12, in BluePill GPIOC, GPIO13
//
static rcc_periph_clken clk = RCC_GPIOC;
static uint32_t port = GPIOC;
static uint16_t pin = GPIO13;

void blink(uint32_t count)
{
  uint32_t ticks = 1000000;

  for (uint32_t k = 0; k < count; k++) {
    gpio_clear(port, pin);
    for (uint32_t i = 0; i < ticks; i++)
      __asm__("nop");

    gpio_set(port, pin);
    for (uint32_t i = 0; i < ticks; i++)
      __asm__("nop");
  }
}

extern "C" {

void vApplicationStackOverflowHook(xTaskHandle *pxTask, signed portCHAR *pcTaskName)
{
  (void) pxTask;
  (void) pcTaskName;

  for (;;) {
    blink(10);
  }
}

} // extern "C"

static void task1(void* args __attribute((unused)))
{
  btr::Example example;

  for (;;) {
    gpio_toggle(port, pin);
    example.hello();
    vTaskDelay(pdMS_TO_TICKS(1000));
  }
}

int main()
{
  rcc_clock_setup_in_hse_8mhz_out_72mhz();

  rcc_periph_clock_enable(clk);
  gpio_set_mode(port, GPIO_MODE_OUTPUT_2_MHZ, GPIO_CNF_OUTPUT_PUSHPULL, pin);

  if (pdPASS ==
      xTaskCreate(task1, "LED", configMINIMAL_STACK_SIZE+100, NULL, configMAX_PRIORITIES-1, NULL))
  {
    blink(2);
  } else {
    blink(5);
  }

  vTaskStartScheduler();

  for (;;);
  return 0;
}
