port module Games.Platformer exposing (main)

import Browser
import Browser.Events
import Html exposing (Html, button, div)
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import Json.Encode as Encode
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time

-- MAIN

main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

-- MODEL
type alias Model  =
    { playerScore : Int }
 
initialModel : Model
initialModel =
     {playerScore = 0 }
 
init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )

-- PORTS

port broadcastScore : Encode.Value -> Cmd msg

type Msg
     = BroadcastScore Encode.Value
     | CountdownTimer Time.Posix
     | GameLoop Float
     | KeyDown String
     | NoOp
     | SetNewItemPositionX Int     

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BroadcastScore value ->
            ( model, broadcastScore value )
        _ -> 
            Debug.log "blurp"
            (model , Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


 -- VIEW
viewBroadcastScoreButton : Model -> Html Msg
viewBroadcastScoreButton model =
    let
        broadcastEvent =
            model.playerScore
                |> Encode.int
                |> BroadcastScore
                |> Html.Events.onClick
    in
    button
        [ broadcastEvent
        , Html.Attributes.class "button"
        ]
        [ text "Broadcast Score Over Socket" ]            

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ viewBroadcastScoreButton model
        ]        