module Tests (..) where

import ElmTest exposing (..)
import StateyTests
import ExampleTests


all : Test
all =
    suite
        "Elm Statey test suite"
        [ StateyTests.tests, ExampleTests.tests ]
