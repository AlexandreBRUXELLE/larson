port module Main exposing (main, Msg)

import Browser
import Browser.Events
-- import Html exposing (..)
import Html exposing (Html, button, div, text, input)
-- import Html.Attributes exposing (..)
import Html.Attributes exposing ( type_, value, placeholder, style)
-- import Html.Events
import Html.Events exposing (onInput)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Encode as Encode
import Random
--import Svg exposing (style)
--import Svg.Attributes exposing (class)
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

type alias Model =
  { command : String
  , args : String
  , post : Bool
  , gameplays : List Gameplay
  , playerScore : Int
  }

type alias Gameplay =
    { playerScore : Int }

-- MODEL --init
initialModel : Model
initialModel =
     { command = ""
     , args = ""
     , post = False
     , gameplays = []
     , playerScore = 0
     }

init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )

-- PORTS
port broadcastScore : Encode.Value -> Cmd msg

port receiveScoreFromPhoenix : (Encode.Value -> msg) -> Sub msg


-- UPDATE

type Msg
  = Command String
  | Args String
  | Post
  | BroadcastScore Encode.Value
  | CountdownTimer Time.Posix
  | GameLoop Float
  | KeyDown String
  | NoOp
  | ReceiveScoreFromPhoenix Encode.Value
  | SetNewItemPositionX Int

decodeGameplay : Decode.Decoder Gameplay
decodeGameplay =
     Decode.map Gameplay
         (Decode.field "player_score" Decode.int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Command command ->
        ( { model | post = False , command = command } , Cmd.none )

    Args args ->
        ( { model | post = False , args = args } , Cmd.none )

    Post ->
        ( { model | post = True} , Cmd.none )

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
view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Command" model.command Command
    , viewInput "text" "Arguments" model.args Args
    , button [ onClick Post ] [ text "Run" ]
    , viewValidation model
    , viewBroadcast model
    ]

viewBroadcast model =
    div []
      [ viewBroadcastScoreButton model
      ]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

viewValidation : Model -> Html msg
viewValidation model =
  if model.post == True then
    div [ style "color" "green" ] [ text "Sent" ]
  else
    div [ style "color" "red" ] [ text "Not sent yet" ]

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

viewGameplayItem : Model -> Gameplay -> Html Msg
viewGameplayItem model gameplay =
    let
        displayScore =
            String.fromInt gameplay.playerScore
    in
    div []
      [  text displayScore ]
