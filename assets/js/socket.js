import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import Comment from './modules/comment';

function buildComments(selector = '.js-comment') {
  let comments = [...document.querySelectorAll(selector)];
  comments.forEach(el => {
    if (!el.comment) {
      new Comment(el);
    }
  });
}

let hooks = {};
hooks.CommentList = {
  mounted() {
    buildComments();
  },
  updated() {
    // build comments again to attach listeners to new nodes added
    buildComments();
    // TODO: phx-update="ignore" on form to avoid "disable" that doesn't get removed on update
    // This is because the new diff won't have the PHX_DISABLED target to then re-enable
    // Also need to figure out how to reset the form only on main form submit so to not clear out with
    // adding a reply
    document.getElementById('main-comment-form').reset();
  }
}

let liveSocket = new LiveSocket("/live", Socket, { hooks });
liveSocket.connect();
