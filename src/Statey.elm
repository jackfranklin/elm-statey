module Statey (..) where

import Dict exposing (Dict)
import List


type State
    = UserState String
    | AnyState


type alias StateRecord a =
    { a | state : State }


type alias Guards a =
    { from : State, to : State, fn : StateRecord a -> Bool }


type alias StateMachine a =
    { states : List State
    , transitions : List ( State, State )
    , guards : List (Guards a)
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


transition : StateMachine a -> StateRecord a -> State -> Result String (StateRecord a)
transition stateMachine record newState =
    if transitionDefined stateMachine ( record.state, newState ) then
        -- TODO: guards
        Ok { record | state = newState }
    else
        Err "Transition not defined"
