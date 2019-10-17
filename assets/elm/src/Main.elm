port module Main exposing (main, Msg)

import Browser
import Browser.Events
-- import Html exposing (..)
import Html exposing (Html, button, div, text, input, h2, li, span, strong, ul)
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
  , playerScore : String
  }

type alias Gameplay =
    { playerScore : String }

-- MODEL --init
initialModel : Model
initialModel =
     { command = ""
     , args = ""
     , post = False
     , gameplays = []
     , playerScore = "__"
     }

init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )

-- PORTS
port broadcastScore : (String)-> Cmd msg

port receiveScoreFromPhoenix : (String -> msg) -> Sub msg


-- UPDATE

type Msg
  = Command String
  | Args String
  | Post
  | BroadcastScore String
  | CountdownTimer Time.Posix
  | GameLoop Float
  | KeyDown String
  | NoOp
  | ReceiveScoreFromPhoenix String
  | SetNewItemPositionX Int

decodeGameplay : Decode.Decoder Gameplay
decodeGameplay =
     Decode.map Gameplay
         (Decode.field "player_score" Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Command command ->
        Debug.log " -- Cmd -- "
        ( { model | post = False , command = command } , Cmd.none )

    Args args ->
        Debug.log " -- Args -- "
        ( { model | post = False , args = args } , Cmd.none )

    Post ->
        Debug.log " -- Post -- "
        ( { model | post = True} , Cmd.none )

    BroadcastScore value ->
        Debug.log " -- Broadcast -- "
        ( model, broadcastScore value )

    ReceiveScoreFromPhoenix incomingJsonData ->
        case Decode.decodeString decodeGameplay incomingJsonData of
            Ok gameplay ->
                Debug.log " -- Successfully received score data. --"
                ( { model | gameplays = gameplay :: model.gameplays }, Cmd.none )
            Err _ ->
                    Debug.log " --  incomingJsonData nok -- "
                    (model , Cmd.none )
    _ ->
        Debug.log "-- msg nok --"
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
    , viewGameplaysList model
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
                |> BroadcastScore
                |> Html.Events.onClick
    in
    button
        [ broadcastEvent
        , Html.Attributes.class "button"
        ]
        [ text "Broadcast Score Over Socket" ]


viewGameplaysList : Model -> Html Msg
viewGameplaysList model =
    ul [ Html.Attributes.class "gameplays-list" ]
        (List.map (viewGameplayItem model) model.gameplays)

viewGameplayItem : Model -> Gameplay -> Html Msg
viewGameplayItem model gameplay =
    let
        displayScore =
            (gameplay.playerScore)
    in
    li [ Html.Attributes.class "gameplay-item" ]
        [ strong [] [ text ("glup" ++ ": ") ]
        , span [] [ text displayScore ]
        ]
