import { Controller } from "@hotwired/stimulus"

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
    const timestamp = new URLSearchParams(window.location.search).get('mock_time') || new Date().toISOString()

    this.frameTarget = document.getElementById('glucose_metrics_display');

    if (this.frameTarget) {
      setTimeout(() => {
        this.frameTarget.src = `/dashboards/glucose_metrics?preceding_timestamp=${timestamp}`;
      }, 1000)
      // Turbo automatically loads the src when it's set
    }

    // this.timeout = setTimeout(async () => {
    //   // Turbo automatically processes the stream response, no need to handle the response.
    //   await fetch(`/dashboards/glucose_metrics?preceding_timestamp=${timestamp}`, {
    //     headers: {
    //       'Accept': 'text/vnd.turbo-stream.html' // <--- Explicitly request Turbo Stream
    //     }
    //   })
    // }, 5000)
  }
}

export default RetryController