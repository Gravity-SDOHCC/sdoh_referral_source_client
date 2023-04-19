import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["activeTable", "completedTable", "flashContainer"];

  connect() {
    const pollUrl = this.element.dataset.pollUrl;
    if (pollUrl) {
      this.pollTasks(pollUrl);
      // this.pollingInterval = setInterval(() => this.pollTasks(pollUrl), 10000);
    }
  }

  disconnect() {
    clearInterval(this.pollingInterval);
  }

  pollTasks(pollUrl) {
    fetch(pollUrl)
      .then((response) => {
        if (response.ok) {
          return response.json();
        } else {
          throw new Error("Failed to poll tasks");
        }
      })
      .then((response) => {
        if (response) {
          if (response.active_table) {
            this.activeTableTarget.innerHTML = response.active_table;
            this.completedTableTarget.innerHTML = response.completed_table;
          }

          if (response.flash) {
            this.flashContainerTarget.innerHTML = `<div class="alert alert-notice alert-dismissible fade show" role="alert">${response.flash} <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>`;
          }
        }
        setTimeout(() => this.pollTasks(pollUrl), 10000);
      })
      .catch((error) => {
        console.error(error);
        setTimeout(() => this.pollTasks(pollUrl), 10000);
      });;
  }
}
