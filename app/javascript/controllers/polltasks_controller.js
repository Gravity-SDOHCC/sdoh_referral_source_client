import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["activeTable", "completedTable", "flashContainer"];

  connect() {
    const pollUrl = this.element.dataset.pollUrl;
    if (pollUrl) {
      this.pollTasks(pollUrl);
      this.pollingInterval = setInterval(() => this.pollTasks(pollUrl), 20000);
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
          if (response.active_table && this.activeTableTarget) {
            this.activeTableTarget.innerHTML = response.active_table;
          }
          if (response.completed_table && this.completedTableTarget) {
            this.completedTableTarget.innerHTML = response.completed_table;
          }
          if (response.flash) {
            this.flashContainerTarget.innerHTML = `<div class="alert alert-info alert-dismissible fade show" data-controller="toasts" role="alert">${response.flash} <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>`;
          }
        }
      })
      .catch((error) => {
        console.error(error);
      });;
  }
}
