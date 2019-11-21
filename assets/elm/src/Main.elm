port module Main exposing (main, Msg)

import Browser
import Browser.Events
-- import Html exposing (..)
import Html exposing (Html, button, div, text, input, h2, li, span, strong, ul, pre)
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

-- elm-menu
import Menu

-- import bootstrap
import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Alert as Alert
import Bootstrap.Spinner as Spinner
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing


-- import elm-ui
import Element exposing (rgb255)
import Element.Background as Background



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
  { fsx : String
  , command : String
  , args : String
  , post : Bool
  , gameplays : List Gameplay
  , playerScore : String
  , laloyCmd : List LaloyCmd
  , howManyToShow : Int
  , autoState : Menu.State
  , selectedlaloyCmd : Maybe LaloyCmd
  , radioState : RadioState
  -- , query : String
  }

type RadioState
    = BuildScript
    | LisaScript

type alias Gameplay =
    { playerScore : String }

type alias Schema =
  { script : String
  , cmd : String
  , params : String
  }

-- MODEL --init
script : String -> (String, Encode.Value)
script value =
  ("fsx", Encode.string value)

cmd : String -> (String, Encode.Value)
cmd value =
  ("cmd", Encode.string value)

params : String -> (String, Encode.Value)
params value =
  ("params", Encode.string value)

json2js : Schema -> Encode.Value
json2js schema =
  Encode.object
    [ script schema.script
    , cmd schema.cmd
    , params schema.params
    ]

initialModel : Model
initialModel =
     { fsx = "build.fsx"
     , command = ""
     , args = ""
     , post = False
     , gameplays = []
     , playerScore = "__"
     , laloyCmd = buildCmds
     , howManyToShow = 5
     , autoState = Menu.empty
     , selectedlaloyCmd = Nothing
     , radioState = BuildScript
     -- , query = ""
     }

init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Cmd.none )

-- PORTS
port broadcastScore : (Encode.Value)-> Cmd msg

port receiveScoreFromPhoenix : (String -> msg) -> Sub msg


-- UPDATE

type Msg
  = SetQuery String
  | SetAutoState Menu.Msg
  | SelectKeyboard String
  | SelectMouse String
  | Preview String
  | Fsx String
  | Command String
  | Args String
  | Clear
  | BroadcastScore Schema
  | CountdownTimer Time.Posix
  | GameLoop Float
  | KeyDown String
  | NoOp
  | ReceiveScoreFromPhoenix String
  | SetNewItemPositionX Int
  | RadioMsg RadioState

type alias LaloyCmd =
    { target : String
    , example : String
    , description : String
    , arguments : String
    }

decodeGameplay : Decode.Decoder Gameplay
decodeGameplay =
     Decode.map Gameplay
         (Decode.field "player_score" Decode.string)


lisaCmds : List LaloyCmd
lisaCmds =
    [ LaloyCmd "TestAndReport" "laloy TestAndReport" "Run all VNR tests + display Allure results" ""
    , LaloyCmd "Build" "laloy Build" "Build the lisa project" ""
    ]

buildCmds : List LaloyCmd
buildCmds =
    [ LaloyCmd "RunVNRTests" "laloy RunVNRTests" "Run all VNR tests (run BuildJenkins before) depends on TestsVNR" ""
    , LaloyCmd "BuildDebug" "laloy BuildDebug" "Build the TestNunit project" ""
    , LaloyCmd "CleanApx" "laloy CleanApx" "Clean the TestNunit project" ""
    , LaloyCmd "XsdToObjClass" "laloy XsdToObjClass vFw=2.10.0.18" "Clean the TestNunit project" "vFw="
    ]

acceptableTarget : String -> List LaloyCmd -> List LaloyCmd
acceptableTarget query laloyCmd =
  let
      lowerQuery =
          String.toLower query
  in
      List.filter (String.contains lowerQuery << String.toLower << .target) laloyCmd


getAtId laloyCmd id =
    List.filter (\getLaloyCmd -> getLaloyCmd.target == id) laloyCmd
        |> List.head
        |> Maybe.withDefault (LaloyCmd "" "" "" "")

getCmds str =
    if (str /= "build.fsx") then
        Debug.log " -- Fsx A -- "
        lisaCmds
    else
        Debug.log " -- Fsx B -- "
        buildCmds

getFsx inFsx =
    if (inFsx /= BuildScript) then
        Debug.log " -- Fsx A -- "
        buildCmds
    else
        Debug.log " -- Fsx B -- "
        lisaCmds

setQuery model id =
    { model
        | command = .target (getAtId model.laloyCmd id)
        , args = .arguments (getAtId model.laloyCmd id)
        , selectedlaloyCmd = Just (getAtId model.laloyCmd id)
    }


resetMenu model =
    { model
        | autoState = Menu.empty
    }


updateConfig : Menu.UpdateConfig Msg LaloyCmd
updateConfig =
    Menu.updateConfig
        { toId = .target
        , onKeyDown =
            \code maybeId ->
                if code == 38 || code == 40 then
                    Maybe.map Preview maybeId

                else if code == 13 then
                    Maybe.map SelectKeyboard maybeId

                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \id -> Just (Preview id)
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just (SelectMouse id)
        , separateSelections = False
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of

    RadioMsg state ->
        ( { model | radioState = state, laloyCmd = (getFsx state) }, Cmd.none )

    Fsx fsx ->
        Debug.log " -- Fsx -- "
        ( { model | fsx = fsx , laloyCmd = (getCmds fsx) } , Cmd.none )

    Command command ->
        Debug.log " -- Cmd -- "
        ( { model | post = False , command = command } , Cmd.none )

    Args args ->
        Debug.log " -- Args -- "
        ( { model | post = False , args = args } , Cmd.none )

    Clear ->
        Debug.log " -- Post -- "
        ( { model | gameplays= [] } , Cmd.none )

    BroadcastScore value ->
        Debug.log " -- Broadcast -- "
        ( {model | post = True }, broadcastScore ( json2js (Schema model.fsx model.command model.args) ))

    ReceiveScoreFromPhoenix incomingJsonData ->
        case Decode.decodeString decodeGameplay incomingJsonData of
            Ok gameplay ->
                Debug.log " -- Successfully received score data. --"
                ( { model | gameplays = gameplay :: model.gameplays , post = False }, Cmd.none )
            Err _ ->
                    Debug.log " --  incomingJsonData nok -- "
                    (model , Cmd.none )

    SetAutoState autoMsg ->
        let
            ( newState, maybeMsg ) =
                Menu.update updateConfig
                    autoMsg
                    model.howManyToShow
                    model.autoState
                    (acceptableTarget model.command model.laloyCmd)

            newModel =
                { model | autoState = newState }
        in
        maybeMsg
            |> Maybe.map (\updateMsg -> update updateMsg newModel)
            |> Maybe.withDefault ( newModel, Cmd.none )

    SelectKeyboard id ->
        let
            newModel =
                setQuery model id
                    |> resetMenu
        in
        ( newModel, Cmd.none )

    SelectMouse id ->
        let
            newModel =
                setQuery model id
                    |> resetMenu
        in
        ( newModel, Cmd.none ) -- Task.attempt (\_ -> NoOp) (Dom.focus "president-input") )

    Preview id ->
        ( { model
            | selectedlaloyCmd =
                Just (getAtId model.laloyCmd id)
            }
        , Cmd.none
        )

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
    [ Alert.simpleLight [] [text "Script .fsx to execute: "]
    , viewRadioScript model
    , viewInput "text" "Command" model.command Command
    , viewInput "text" "Arguments" model.args Args
    , button [ onClick Clear ] [ text "Clear Results" ]
    , viewValidation model
    , viewBroadcast model
    , viewSpinner model
    , viewGameplaysList model
    , viewMenu model
    , viewCmdHelp model
    ]


viewSpinner : Model -> Html Msg
viewSpinner model =
  if model.post == True then
    div [] [
        Spinner.spinner
            [ Spinner.grow
            , Spinner.large
            , Spinner.color Text.secondary
            , Spinner.attrs [ Spacing.mb3 ]
            ]
            []
        , text "Loading..."
    ]
  else
    div [] []

viewRadioScript : Model -> Html Msg
viewRadioScript model =
    ButtonGroup.radioButtonGroup  []
        [ ButtonGroup.radioButton
            (model.radioState == BuildScript)
            [ Button.primary , Button.onClick <| RadioMsg BuildScript ]
            [ text "build.fsx" ]
        , ButtonGroup.radioButton
            (model.radioState == LisaScript)
            [ Button.primary, Button.small , Button.onClick <| RadioMsg LisaScript ]
            [ text "lisa.fsx" ]
        ]

viewCmdHelp : Model -> Html msg
viewCmdHelp model =
    div [  Html.Attributes.class "target-help" ]
        [
          div [ Html.Attributes.class "target-description" ] [ text ( Maybe.withDefault " "  (model.selectedlaloyCmd |> Maybe.map .description)) ]
        , div [ Html.Attributes.class "target-example" ] [ text ( Maybe.withDefault " "  (model.selectedlaloyCmd |> Maybe.map .example)) ]
        ]


viewMenu : Model -> Html.Html Msg
viewMenu model =
    Html.div [ Html.Attributes.class "autocomplete-menu" ]
        [ Html.map SetAutoState <|
            Menu.view viewConfig
                model.howManyToShow
                model.autoState
                (acceptableTarget model.command model.laloyCmd)
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
            (Schema model.fsx model.command model.args)
                |> BroadcastScore
                |> Html.Events.onClick
    in
    button
        [ broadcastEvent
        , Html.Attributes.class "button"
        ]
        [ text "Run Command" ]


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
        [ strong [] [ text ("Result" ++ ": ") ]
        , pre [] [ text displayScore ]
        ]

viewConfig : Menu.ViewConfig LaloyCmd
viewConfig =
    let
        customizedLi keySelected mouseSelected laloyCmd =
            { attributes =
                [ Html.Attributes.classList
                    [ ( "autocomplete-item", True )
                    , ( "key-selected", keySelected || mouseSelected )
                    ]
                , Html.Attributes.id laloyCmd.target
                ]
            , children = [ Html.text laloyCmd.target ]
            }
    in
    Menu.viewConfig
        { toId = .target
        , ul = [ Html.Attributes.class "autocomplete-list" ]
        , li = customizedLi
        }

{-
sectionConfig : Menu.SectionConfig LaloyCmd (List LaloyCmd)
sectionConfig =
    Menu.sectionConfig
        { toId = .target
        , getData = .description
        , ul = [ Html.Attributes.class "autocomplete-section-list" ]
        , li =
            \section ->
                { nodeType = "div"
                , attributes = [ Html.Attributes.class "autocomplete-section-item" ]
                , children =
                    [ Html.div [ Html.Attributes.class "autocomplete-section-box" ]
                        [ Html.strong [ Html.Attributes.class "autocomplete-section-text" ] [ Html.text "poet" ]
                        ]
                    ]
                }
        }
-}
