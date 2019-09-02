// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// Phoenix Dependencies

import "phoenix_html"

// import socket from "./socket"

import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

// Font Awesome

import '@fortawesome/fontawesome-free/js/all'

import JSONEditor from 'jsoneditor'

window.JSONEditor = JSONEditor;

function initialize_jsoneditor() {
  var containers = $("div[name='jsoneditor']");

  containers.forEach(construct_editor);
}

function construct_editor(container) {
  new JSONEditor(container, container.attr("options"), container.attr("json"));
}