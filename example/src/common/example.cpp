// Copyright (C) 2019 Bolt Robotics <info@boltrobotics.com>
// License: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

// SYSTEM INCLUDES
#if BTR_X86 > 0
#include <iostream>
#elif BTR_ARD > 0
#include <Arduino.h>
#endif

// PROJECT INCLUDES
#include "example.hpp"  // class implemented

namespace btr
{

/////////////////////////////////////////////// PUBLIC /////////////////////////////////////////////

//============================================= LIFECYCLE ==========================================

Example::Example()
{
}

//============================================= OPERATIONS =========================================

bool Example::hello()
{
#if BTR_X86 > 0
  std::cout << "Hello" << std::endl;
#elif BTR_STM32 > 0
#elif BTR_AVR > 0
#elif BTR_ARD > 0
  Serial.println("Hello");
#endif
  return true;
}

/////////////////////////////////////////////// PROTECTED //////////////////////////////////////////

//============================================= OPERATIONS =========================================

/////////////////////////////////////////////// PRIVATE ////////////////////////////////////////////

//============================================= OPERATIONS =========================================

} // namespace btr
