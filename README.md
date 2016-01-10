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
    Err err -> ...
```

