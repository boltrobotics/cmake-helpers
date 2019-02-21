// Copyright (C) 2019 Bolt Robotics <info@boltrobotics.com>
// License: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

// SYSTEM INCLUDES
#include <avr/io.h>
#include <util/delay.h>

// PROJECT INCLUDES
#include "example.hpp"

// Mega2560
#define DELAY     500
#define LED_DDR   DDRB
#define LED_PORT  PORTB
#define LED_PIN   PB7

btr::Example example;

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
