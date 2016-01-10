module Tests (..) where

import ElmTest exposing (..)
import StateyTests


all : Test
all =
    suite
        "Elm Statey test suite"
        [ StateyTests.tests ]
