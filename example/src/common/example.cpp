// Copyright (C) 2019 Sergey Kapustin <kapucin@gmail.com>

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

// SYSTEM INCLUDES
#if BTR_X86 > 0
#include <iostream>
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
#elif BTR_ESP32 >0
#elif BTR_STM32 > 0
#elif BTR_AVR > 0
#endif
  return true;
}

/////////////////////////////////////////////// PROTECTED //////////////////////////////////////////

//============================================= OPERATIONS =========================================

/////////////////////////////////////////////// PRIVATE ////////////////////////////////////////////

//============================================= OPERATIONS =========================================

} // namespace btr
