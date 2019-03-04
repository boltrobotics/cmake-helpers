// Copyright (C) 2019 Bolt Robotics <info@boltrobotics.com>
// License: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

/** @file */

// SYSTEM INCLUDES
#include <avr/io.h>
#include <util/delay.h>

// PROJECT INCLUDES
#include "example.hpp"

/** @ingroup BUILTIN_LED */
#define DELAY     500     //!< Sleep delay in milliseconds.

/**
 * @defgroup BUILTIN_LED Define built-in LED parameters for atmega2560.
 * @{
 */
/** Data direction register. */
#define LED_DDR   DDRB
#define LED_PORT  PORTB   //!< LED port.
#define LED_PIN   PB7     //!< LED pin.

/** @} BUILTIN_LED */

/** An instance of a class Example. */
btr::Example example;

/**
 * Blink a led every ::DELAY milliseconds and invoke btr::Example::hello().
 * @return 0 on success, -1 on failure
 */
int main()
{
  LED_DDR |= (1 << LED_PIN);

  while (1) {
    LED_PORT |= (1 << LED_PIN);
    _delay_ms(DELAY);

    example.hello();

    LED_PORT &= ~(1 << LED_PIN);
    _delay_ms(DELAY);
  }

  return 0;
}
