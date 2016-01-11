module ExampleTests (..) where

{-| these tests serve as a good intro to the library
-}

import Statey exposing (..)
import ElmTest exposing (..)


type alias Person =
    StateRecord { name : String }


startState =
    makeState "start"


tiredState =
    makeState "tired"


sleepState =
    makeState "sleep"


stateMachine : StateMachine Person
stateMachine =
    { states = [ startState, tiredState, sleepState ]
    , transitions =
        [ ( startState, tiredState )
        , ( tiredState, sleepState )
        , ( sleepState, startState )
        ]
    , guards =
        [ { from = tiredState, to = sleepState, fn = \person -> person.name /= "Jack" }
        ]
    }


person =
    { name = "Jack", state = startState }


tiredPerson =
    { name = "Jack", state = tiredState }


tests : Test
tests =
    suite
        "Example tests"
        [ test
            "it can tell you the state of a record"
            (assertEqual startState (getState person))
        , test
            "it can transition a person through a state"
            (assertEqual
                (Ok { person | state = tiredState })
                (transition stateMachine tiredState person)
            )
        , test
            "but only if the transition is valid"
            (assertEqual
                (Err TransitionNotDefined)
                (transition stateMachine sleepState person)
            )
        , test
            "a guard that returns False stops a transition"
            (assertEqual
                (Err GuardPreventedTansition)
                (transition stateMachine sleepState tiredPerson)
            )
        ]
