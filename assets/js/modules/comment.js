import autosize from 'autosize';

/**
 * The comment class is a stateful class to manage dynamic UI elements related to comments
 * that have already been created
 *
 * - toggle reply button
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

    // attach instance of this class to do things with it later
    // like avoid rebuilding comments
    this.container.comment = this;
  }

  attach() {
    this.replyForm = this.container.querySelector('form');
    this.replyTextArea = this.container.querySelector('textarea');
    this.replyButton = this.container.querySelector('.js-comment-reply');

    if (this.replyButton) {
      this.replyButton.addEventListener('click', _ => {
        this.toggleReplyForm()
      });
    }

    if (this.replyForm) {
      // LiveView does not include form data in phx-key*** events, so we manually manage here
      // TODO: see socket.js for work to clear form
      // This will not work atm b/c form submit in LV is called first
      // this.replyForm.addEventListener('submit', event => {
      //   this.replyForm.reset();
      // });

      this.replyForm.addEventListener('keydown', event => {
        if ((event.metaKey || event.ctrlKey) && event.key == 'Enter') {
          this.replyForm.dispatchEvent(
            new Event('submit', { bubbles: true, cancelable: true, detail: undefined })
          );
        }
      });
    }
  }

  toggleReplyForm() {
    if (this.replyForm.classList.contains('is-hidden')) {
      this.openReplyForm();
    } else {
      this.closeReplyForm();
    }
  }

  openReplyForm() {
    this.replyForm.classList.remove('is-hidden');
    this.replyTextArea.focus();
    this.replyButton.textContent = 'cancel';
  }

  closeReplyForm() {
    this.replyForm.classList.add('is-hidden');
    this.replyButton.textContent = 'reply';
  }

  clearReplyForm() {
    this.replyForm.reset();
    autosize.update(this.replyTextArea);
  }

  autosize() {
    setTimeout(function() {
      autosize(this.replyTextArea);
    }, 50);
  }
}
