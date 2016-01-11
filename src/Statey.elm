module Statey (StateyError(TransitionNotDefined, GuardPreventedTansition), StateMachine, State, StateRecord, makeState, getState, getStates, transition) where

{-| This library provides a simple state machine implementation in Elm.

# Making a state machine
@docs StateMachine, makeState, State, StateRecord

# Getting the state
@docs getState, getStates

# Transitioning
@docs transition

# Errors
@docs StateyError
-}


{-| Represents an error in a state transition.
-}
type StateyError
    = TransitionNotDefined
    | GuardPreventedTansition


{-| Represents a state. This can either be a user given state, or `AnyState`,
which is used in guards to denote that it applies to any state
-}
type State
    = UserState String
    | AnyState


{-| A `StateRecord` is just any record that has a `state : State` property on it. Every state machine is created with one of these as its type, and most of the functions expect to be given one.

The records that you want to use in the state machine should be based off this:

    type alias Person = StateRecord { name : String }
-}
type alias StateRecord a =
    { a | state : State }


{-| You can guard transitions by defining guards. These are called when a transition occurs that matches the `from` and `to` properties, at which point `fn` will be called, along with the record that is being transitioned.

    { from = startState, to = endState, fn: (\record -> record.name /= "Jack") }
-}
type alias Guard a =
    { from : State, to : State, fn : StateRecord a -> Bool }


{-| A state machine contains a list of valid states, a list of transitions and a list of guards.

A state machine is given a record type that it will always expect to be given. This type should be an extensible record that extends `StateRecord`:

    type alias Person = StateRecord { name: String }

    stateMachine : StateMachine Person
    stateMachine =
        { states = [ startState, tiredState, sleepState ]
        , transitions =
            [ ( startState, tiredState )
            , ( tiredState, sleepState )
            , ( sleepState, startState )
            ]
        , guards = []
        }

-}
type alias StateMachine a =
    { states : List State
    , transitions : List ( State, State )
    , guards : List (Guard a)
    }


{-| Make a state from a string. This is the method you should use to create states
for your state machine. The string given doesn't matter, just make it relevant to
your application.

    startState = makeState "start"
-}
makeState : String -> State
makeState str =
    UserState str


{-| given a particular record, return the state of it. This is an alias to `.state`
currently, but you should use is in case the underlying abstractions change

    getState { name = "jack", state = startState } == startState

-}
getState : StateRecord a -> State
getState =
    .state


{-| given a state machine, return its list of states. An alias to `.states`.
-}
getStates : StateMachine a -> List State
getStates =
    .states


transitionDefined : StateMachine a -> ( State, State ) -> Bool
transitionDefined stateMachine transition =
    List.any ((==) transition) stateMachine.transitions


guardAllowsTransition : StateMachine a -> StateRecord a -> State -> Bool
guardAllowsTransition stateMachine record newState =
    stateMachine.guards
        |> List.filter
            (\g ->
                (g.from == record.state || g.from == AnyState) && (g.to == newState || g.to == AnyState)
            )
        |> List.all (\{ fn } -> (fn record) == True)


{-| Transition the given record from its state to the new state. The result will
either be an `Ok newRecord` or `Err StateyErr`.

    startState = makeState "start"
    middleState = makeState "middle"
    endState = makeState "end"

    stateMachine : StateMachine { name : String }
    stateMachine =
        { states = [ startState, middleState, endState ]
        , transitions = [ ( startState, middleState ), ( middleState, endState ) ]
        , guards = []
        }

    person = { name = "Jack", state = startState }

    case transition stateMachine middleState person of
        Ok newPerson ->
            newPerson
        Err err ->
            err == GuardPreventedTansition || err == TransitionNotDefined
-}
transition : StateMachine a -> State -> StateRecord a -> Result StateyError (StateRecord a)
transition stateMachine newState record =
    if transitionDefined stateMachine ( record.state, newState ) then
        if guardAllowsTransition stateMachine record newState then
            Ok { record | state = newState }
        else
            Err GuardPreventedTansition
    else
        Err TransitionNotDefined
