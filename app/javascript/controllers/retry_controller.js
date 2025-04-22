import { Controller } from "@hotwired/stimulus"

/**
 * This Stimulus controller can be used to refresh a turbo frame once a second.
 *
 * Usage:
 *       <turbo-frame id="some_unique_id" >
 *         <div
 *           data-controller="retry"
 *           data-frame="some_unique_id"
 *           data-url="<%= url_to_poll %>"
 *           data-enabled="<%= content_is_ready? %>"
 *         >
 *           Your content here
 *         </div>
 *       </turbo-frame>
 */
class RetryController extends Controller {
  connect() {
    this.poll()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  poll() {
    const turboFrameId = this.element.dataset.frame

    if (!turboFrameId) {
      throw new Error(`RetryController requires a data-frame attribute with the id of the turbo frame to refresh.`)
    }

    const turboFrame = document.getElementById(turboFrameId);

    if (!turboFrame) {
      throw new Error(`RetryController can't retry... no turbo-frame with id "${turboFrameId}" found.`)
    }

    const src = this.element.dataset.src

    if (!src) {
      throw new Error(`RetryController requires a data-src attribute with the url to retry.`)
    }

    const enabled = this.element.dataset.enabled

    // For simplicity in rendering, it's sometimes easier to disable the retry controller with a boolean.
    if (enabled === "false") {
      return
    }

    // If everything is ready, all we need to do is wait 1s and Turbo will refresh the content when we set the src.
    setTimeout(() => {
      turboFrame.src = src
    }, 1000)
  }
}

export default RetryController