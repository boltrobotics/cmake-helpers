// Copyright (C) 2019 Bolt Robotics <info@boltrobotics.com>
// License: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

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
