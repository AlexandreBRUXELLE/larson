// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

import {Socket} from "phoenix"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

let socket = new Socket("/socket", {})

socket.connect()

// Elm
import { Elm } from "../elm/src/Main2.elm";

let app = Elm.Main2.init({
  node: document.getElementById("elm-container")
})

// elm -- channel
let channel = socket.channel("score:platformer", {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

app.ports.broadcastScore.subscribe(function (scoreData) {
  console.log(`Broadcasting ${scoreData} score data from Elm using the broadcast Score port.`);
  channel.push("broadcast_score", { player_score: scoreData });
});

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
