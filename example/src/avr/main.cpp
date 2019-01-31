// Copyright (C) 2019 Bolt Robotics <info@boltrobotics.com>
// License: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

// SYSTEM INCLUDES
#include <Arduino.h>

// PROJECT INCLUDES
#include "example.hpp"

btr::Example example;

void setup()
{
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop()
{
	digitalWrite(LED_BUILTIN, HIGH);
  delay(1000);

  example.hello();

  digitalWrite(LED_BUILTIN, LOW);
  delay(1000);   
}
