import autosize from 'autosize';

/**
 * The comment class is manages dynamic UI elements related to comments
 *
 * - submit form and throw event up to live_view
 * - autosize comment boxes to fit text
 *
 * @module Comment
 */
export default class Comment {
  constructor(container) {
    this.container = container;
    this.attach();
    this.autosize();
  }

  attach() {
    this.replyForm = this.container;
    this.replyTextArea = this.container.querySelector('textarea');

    if (this.replyForm) {
      this.replyForm.addEventListener('keydown', event => {
        if ((event.metaKey || event.ctrlKey) && event.key == 'Enter') {
          this.replyForm.dispatchEvent(
            new Event('submit', { bubbles: true, cancelable: true, detail: undefined })
          );
        }
      });
    }
  }

  autosize() {
    setTimeout(function() {
      autosize(this.replyTextArea);
    }, 50);
  }
}
