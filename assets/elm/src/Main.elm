module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

-- MAIN

main =
  Browser.sandbox { init = init, update = update, view = view }

-- MODEL

type alias Model =
  { command : String
  , args : String
  }


init : Model
init =
  Model "" ""

-- UPDATE


type Msg
  = Command String
  | Args String

update : Msg -> Model -> Model
update msg model =
  case msg of
    Command command ->
      { model | command = command }

    Args args ->
      { model | args = args }

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Command" model.command Command
    , viewInput "text" "Arguments" model.args Args
    , viewValidation model
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if model.command == model.command then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Blurp" ]