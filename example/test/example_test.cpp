// Copyright (C) 2019 Sergey Kapustin <kapucin@gmail.com>

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

// SYSTEM INCLUDES
#include <gtest/gtest.h>

// PROJECT INCLUDES
#include "example.hpp"

class ExampleTest : public testing::Test
{
public:

// LIFECYCLE

  ExampleTest()
  {
  }

  void SetUp() override
  {
  }

  void TearDown() override
  {
  }

protected:

// ATTRIBUTES

  btr::Example e;
};

//--------------------------------------------------------------------------------------------------
// Tests {

TEST_F(ExampleTest, hello)
{
  ASSERT_EQ(true, e.hello());
}
