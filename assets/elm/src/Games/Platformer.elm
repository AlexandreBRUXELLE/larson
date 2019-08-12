port module Games.Platformer exposing (main)

import Browser
import Browser.Events
import Html exposing (Html, button, div, h2, li, span, strong, ul)
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
    { gameplays : List Gameplay,
      playerScore : Int }

type alias Gameplay =
    { playerScore : Int }
 
initialModel : Model
initialModel =
     {gameplays = [],
     playerScore = 2 }
 
init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )

-- PORTS

port broadcastScore : Encode.Value -> Cmd msg

port receiveScoreFromPhoenix : (Encode.Value -> msg) -> Sub msg


type Msg
     = BroadcastScore Encode.Value
     | CountdownTimer Time.Posix
     | GameLoop Float
     | KeyDown String
     | NoOp
     | ReceiveScoreFromPhoenix Encode.Value
     | SetNewItemPositionX Int     

-- UPDATE

decodeGameplay : Decode.Decoder Gameplay
decodeGameplay =
     Decode.map Gameplay
          Decode.field "player_score" (Decode.int+1)
          


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BroadcastScore value ->
            ( model, broadcastScore value )
        ReceiveScoreFromPhoenix incomingJsonData ->
            case Decode.decodeValue decodeGameplay incomingJsonData of
                Ok gameplay ->
                    Debug.log "Successfully received score data."
                    ( { model | gameplays = gameplay :: model.gameplays }, Cmd.none )
                Err _ ->
                        Debug.log "blurp"
                        (model , Cmd.none )
        _ -> 
            Debug.log "blurp"
            (model , Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
        Sub.batch
            [ receiveScoreFromPhoenix ReceiveScoreFromPhoenix ]


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
        [ viewBroadcastScoreButton model,
          viewGameplaysList model
        ]

viewGameplaysList : Model -> Html Msg
viewGameplaysList model =
    ul [ Html.Attributes.class "gameplays-list" ]
        (List.map (viewGameplayItem model) model.gameplays)

viewGameplayItem : Model -> Gameplay -> Html Msg
viewGameplayItem model gameplay =
    let
        displayScore =
            String.fromInt (gameplay.playerScore+1)
    in
    li [ Html.Attributes.class "gameplay-item" ]
        [ strong [] [ text ("glup" ++ ": ") ]
        , span [] [ text displayScore ]
        ]