// app/javascript/controllers/taskform_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "categorySelect",
    "requestSelect",
    "status",
    "priority",
    "occurrence",
    "occurrenceDate",
    "condition",
    "goal",
    "performer",
    "consent",
    "submitButton",
  ];

  connect() {
    this.requestOptionsJSON = JSON.parse(this.data.get("requestOptions"));
    this.categorySelectTarget.addEventListener(
      "change",
      this.handleCategoryChange.bind(this)
    );

    // Add event listener for modal show event
    const modalElement = document.getElementById("add-referral-modal");
    modalElement.addEventListener("shown.bs.modal", () => {
      this.populateFieldsRandomly();
    });
    // Add event listener for the submit button
    this.submitButtonTarget.addEventListener(
      "click",
      this.handleSubmit.bind(this)
    );
  }

  handleCategoryChange() {
    const selectedCategory = this.categorySelectTarget.value;
    this.updateRequestOptions(selectedCategory);
    this.populateFieldsRandomly();
  }

  handleSubmit(event) {
    event.preventDefault(); // Prevent the default form submission behavior
    const formElement = document.getElementById("task-form");
    formElement.submit(); // Manually submit the form
  }

  updateRequestOptions(selectedCategory) {
    this.requestSelectTarget.innerHTML = "";
    this.requestSelectTarget.disabled = true;

    if (!selectedCategory) return;

    const requestOptions = this.requestOptionsJSON[selectedCategory] || [];

    requestOptions.forEach(requestOption => {
      const opt = document.createElement("option");
      opt.value = requestOption[1];
      opt.text = requestOption[0];
      this.requestSelectTarget.add(opt);
      this.requestSelectTarget.disabled = false;
    });
  }

  populateFieldsRandomly() {
    // this.setRandomValue(this.statusTarget);
    this.statusTarget.selectedIndex = 1;
    this.setRandomValue(this.priorityTarget.parentNode, true); // Pass the parentNode for radio buttons
    this.setRandomValue(this.occurrenceTarget);
    this.setRandomValue(this.conditionTarget);
    this.setRandomValue(this.goalTarget);
    this.setRandomValue(this.performerTarget);
    this.setRandomValue(this.consentTarget);

    this.setRandomFutureDate(this.occurrenceDateTarget);
  }


  setRandomValue(element, isRadio = false) {
    if (isRadio) {
      const radios = Array.from(element.querySelectorAll("input[type=radio]"));
      const randomIndex = Math.floor(Math.random() * radios.length);
      radios[randomIndex].checked = true;
    } else {
      const options = element.options;
      const randomIndex = Math.floor(Math.random() * options.length);
      element.selectedIndex = randomIndex;
    }
  }


  setRandomFutureDate(dateElement) {
    const date = new Date();
    date.setDate(date.getDate() + Math.floor(Math.random() * 365) + 1);
    dateElement.valueAsDate = date;
  }
}
