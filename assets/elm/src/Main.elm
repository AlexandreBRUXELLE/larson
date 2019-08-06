module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Html.Events exposing (onClick)

-- MAIN

main =
  Browser.sandbox { init = init, update = update, view = view }

-- MODEL

type alias Model =
  { command : String
  , args : String
  , post : Bool
  }


init : Model
init =
  Model "" "" False

-- UPDATE


type Msg
  = Command String
  | Args String
  | Post

update : Msg -> Model -> Model
update msg model =
  case msg of
    Command command ->
      { model | post = False , command = command }

    Args args ->
      { model | post = False , args = args }
    
    Post ->
      { model | post = True}
      

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Command" model.command Command
    , viewInput "text" "Arguments" model.args Args
    , button [ onClick Post ] [ text "Run" ]
    , viewValidation model
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