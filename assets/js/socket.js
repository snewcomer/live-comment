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

let liveSocket = new LiveSocket("/live", Socket, {hooks: hooks});
liveSocket.connect();
