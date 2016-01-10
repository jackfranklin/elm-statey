# Statey

A state machine library, written in Elm. Very much a work in progress!

## Usage

```elm
import Statey exposing (..)

-- first, define your states
-- statey provides `makeState` for this:

startState = makeState "start"
middleState = makeState "middle"
endState = makeState "end"

-- define your state machine
-- a state machine is a `StateMachine a`
-- where `a` is the properties on the record that you want to have
-- each record also must have a `state` property

stateMachine : StateMachine { name : String }
stateMachine =
    -- the states in the state machine
    { states = [ startState, middleState, endState ]
    -- the allowed transitions in the form of (from, to)
    , transitions = [ ( startState, middleState ), ( middleState, endState ) ]
    -- guard functions for transitions (see below)
    , guards = []
    }

-- now, we can transition a record
-- somewhere in your code:

person = { name = "Jack", state = startState }
case transition stateMachine person middleState of
    Ok newPerson -> newPerson.state == middleState
    Err err -> -- this won't happen here, transition is valid

-- now, let's see if we try to do an invalid transition

person = { name = "Jack", state = startState }
-- invalid, no (startState, endState) defined
case transition stateMachine person endState of
    Ok newPerson -> ---
    Err err -> err == TransitionNotDefined
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
