import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import Comment from './modules/comment';

function buildComments(el) {
  new Comment(el);
}

let hooks = {};

hooks.Comment = {
  mounted() {
    buildComments(this.el);
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: hooks, params: {_csrf_token: csrfToken}});
liveSocket.connect();
