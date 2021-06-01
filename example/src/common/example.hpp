// Copyright (C) 2019 Sergey Kapustin <kapucin@gmail.com>

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#ifndef _btr_Example_hpp_
#define _btr_Example_hpp_

// SYSTEM INCLUDES

// PROJECT INCLUDES

namespace btr
{

/**
 * A one line description of the class.
 *
 * A longer description.
 */
class Example
{
public:

// LIFECYCLE

  /**
    * Ctor.
    */
  Example();

// OPERATIONS

  /** Print text on standard output.
   * @return true
   */ 
  bool hello();

private:

// OPERATIONS

// ATTRIBUTES

}; // class Example

//==================================================================================================
//                                              INLINE
//==================================================================================================

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                                              PUBLIC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//============================================= LIFECYCLE ==========================================

//============================================= OPERATIONS =========================================

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                                              PRIVATE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//============================================= OPERATIONS =========================================

} // namespace btr

#endif // _btr_Example_hpp_
