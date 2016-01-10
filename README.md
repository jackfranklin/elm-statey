# Statey

A state machine library, written in Elm. Very much a work in progress!

[View the docs on Elm Package](http://package.elm-lang.org/packages/jackfranklin/elm-statey/1.0.0/Statey).

The [example tests](https://github.com/jackfranklin/elm-statey/blob/master/test/ExampleTests.elm) aim to be a good Elm file to take as your starting point for using this library.

## Usage (taken from example tests)

```elm
import Statey exposing (..)
import ElmTest exposing (..)

-- define our custom type Person, which is a record with a `name` property
-- that extends `StateRecord`, which requires a `state : State` property
type alias Person =
    StateRecord { name : String }


-- make some states
startState =
    makeState "start"


tiredState =
    makeState "tired"


sleepState =
    makeState "sleep"


-- create the state machine, telling it it should expect records to be of type Person
stateMachine : StateMachine Person
stateMachine =
    { states = [ startState, tiredState, sleepState ]
    , transitions =
        -- the valid transitions in the form of (from, to)
        [ ( startState, tiredState )
        , ( tiredState, sleepState )
        , ( sleepState, startState )
        ]
    , guards =
        -- guards, which will be called before a transition is confirmed
        -- and the transition will be cancelled if the fn returns false
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
                (transition stateMachine person tiredState)
            )
        , test
            "but only if the transition is valid"
            (assertEqual
                (Err TransitionNotDefined)
                (transition stateMachine person sleepState)
            )
        , test
            "a guard that returns False stops a transition"
            (assertEqual
                (Err GuardPreventedTansition)
                (transition stateMachine tiredPerson sleepState)
            )
        ]
```

## Guards

You can also add guards into your state machine to protect against certain transitions:

```elm
guardedStateMachine =
    { states = [ startState, middleState, endState ]
    , transitions = [ ( startState, middleState ), ( middleState, endState ) ]
    , guards =
        [ { from = startState, to = middleState, fn = (\_ -> False) }
        ]
    }


person = { name = "Jack", state = startState }
-- invalid, guard from start -> middle returns False
case transition stateMachine person middleState of
    Ok newPerson -> ---
    Err err -> err == GuardPreventedTansition
```

Guard callbacks are passed the record:

```elm
-- the guard callback is given the record:

guardedStateMachine =
    { states = [ startState, middleState, endState ]
    , transitions = [ ( startState, middleState ), ( middleState, endState ) ]
    , guards =
        [ { from = startState, to = middleState, fn = (\person -> person.name /= "Jack") }
        ]
    }


person = { name = "Jack", state = startState }
-- invalid, person.name == "Jack"
case transition stateMachine person middleState of
    Ok newPerson -> ---
    Err err -> err == GuardPreventedTansition
```
