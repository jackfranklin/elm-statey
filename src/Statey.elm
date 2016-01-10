module Statey (..) where

import Dict exposing (Dict)
import List


type StateyError
    = TransitionNotDefined
    | GuardPreventedTansition


type State
    = UserState String
    | AnyState


type alias StateRecord a =
    { a | state : State }


type alias Guard a =
    { from : State, to : State, fn : StateRecord a -> Bool }


type alias StateMachine a =
    { states : List State
    , transitions : List ( State, State )
    , guards : List (Guard a)
    }


makeState : String -> State
makeState str =
    UserState str


getState : StateRecord a -> State
getState =
    .state


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


transition : StateMachine a -> StateRecord a -> State -> Result StateyError (StateRecord a)
transition stateMachine record newState =
    if transitionDefined stateMachine ( record.state, newState ) then
        if guardAllowsTransition stateMachine record newState then
            Ok { record | state = newState }
        else
            Err GuardPreventedTansition
    else
        Err TransitionNotDefined
