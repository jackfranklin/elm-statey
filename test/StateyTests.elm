module StateyTests (..) where

import ElmTest exposing (..)
import Dict
import Statey exposing (..)


startState =
    makeState "start"


middleState =
    makeState "middle"


endState =
    makeState "end"


stateMachine : StateMachine { name : String }
stateMachine =
    { states = [ startState, middleState, endState ]
    , transitions = [ ( startState, middleState ), ( middleState, endState ) ]
    , guards = []
    }


creatingAStateMachine =
    let
        expectedStates = [ startState, middleState, endState ]
    in
        test
            "it can create a state machine"
            (assertEqual expectedStates (getStates stateMachine))


transitioningToValidStates =
    let
        person = { name = "Jack", state = startState }

        newPerson = { person | state = middleState }
    in
        test
            "it can transition a record"
            (assertEqual (Ok newPerson) (transition stateMachine person middleState))


transitioningToInvalidStateErrors =
    let
        person = { name = "Jack", state = endState }
    in
        test
            "it returns Err when transition is not allowed"
            (assertEqual
                (Err TransitionNotDefined)
                (transition stateMachine person middleState)
            )


gettingStateOfRecordInStateMachine =
    test
        "it can tell the state of a record"
        (assertEqual startState (getState { name = "Jack", state = startState }))


guardPreventsProgressionTest =
    let
        guardedStateMachine =
            { states = [ startState, middleState, endState ]
            , transitions = [ ( startState, middleState ), ( middleState, endState ) ]
            , guards =
                [ { from = startState, to = middleState, fn = (\_ -> False) }
                ]
            }

        person = { name = "Jack", state = startState }
    in
        test
            "guards that return false prevent transition"
            (assertEqual (Err GuardPreventedTansition) (transition guardedStateMachine person middleState))


tests : Test
tests =
    suite
        "Statey tests"
        [ creatingAStateMachine
        , gettingStateOfRecordInStateMachine
        , transitioningToValidStates
        , transitioningToInvalidStateErrors
        , guardPreventsProgressionTest
        ]
