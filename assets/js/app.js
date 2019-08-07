// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"


// Elm
import { Elm } from "../elm/src/Main.elm"

const platformer=document.querySelector("#platformer");

Elm.Main.init({
  node: document.getElementById("elm-container")
}) 

if (platformer) {
   console.log(`Debug 1`);

   let app = Elm.Games.Platformer.init({ node: platformer });
    
   app.ports.broadcastScore.subscribe(function (scoreData) {
     console.log(`Broadcasting ${scoreData} score data from Elm using the broadcastScore port.`);
     // Later, we'll push the score data to the Phoenix channel
   });
}

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
