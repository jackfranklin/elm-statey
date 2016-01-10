module StateMachineExample (..) where

import Statey exposing (StateMachine, State, makeStates)


type TurnStates
    = Start
    | PlaceTile
    | PlacePlayer
    | PickUpPlayer
    | End


type alias Turn =
    StateRecord { player : String }


turnStates : Dict String State
turnStates =
    makeStates [ "start", "placeTile", "placePlayer", "pickUpPlayer", "end" ]


turnStateMachine : StateMachine
turnStateMachine =
    { states =
        [ Start, PlaceTile, PlacePlayer, PickUpPlayer, End ]
    , transitions =
        [ ( Start, PlaceTile )
        , ( PlaceTile, PlacePlayer )
        , ( PlacePlayer, PickUpPlayer )
        , ( PlacePlayer, End )
        , ( PickUpPlayer, End )
        ]
    , guards =
        [ { from = Start, to = AnyState, fn = \_ -> True }
        ]
    }


main =
    let
        myTurn = { player = "Jack", state = Start }

        newTurn = transition turnStateMachine myTurn PlaceTile
    in
        case newTurn of
            Ok turn ->
                True

            Err _ ->
                False
