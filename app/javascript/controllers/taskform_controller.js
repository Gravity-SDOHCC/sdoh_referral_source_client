// app/javascript/controllers/taskform_controller.js
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "categorySelect",
    "requestSelect",
    "status",
    "priority",
    "occurrence",
    "condition",
    "goal",
    "performer",
    "consent",
  ];

  connect() {
    this.categorySelectTarget.addEventListener(
      "change",
      this.handleCategoryChange.bind(this)
    );
  }

  handleCategoryChange() {
    const selectedCategory = this.categorySelectTarget.value;
    this.updateRequestOptions(selectedCategory);
    this.populateFieldsRandomly();
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
    this.setRandomValue(this.statusTarget);
    this.setRandomValue(this.priorityTarget, true);
    this.setRandomValue(this.occurrenceTarget);
    this.setRandomValue(this.conditionTarget);
    this.setRandomValue(this.goalTarget);
    this.setRandomValue(this.performerTarget);
    this.setRandomValue(this.consentTarget);

    this.setRandomFutureDate(this.occurrenceTarget);
  }

  setRandomValue(selectElement, isRadio = false) {
    const options = isRadio
      ? selectElement.querySelectorAll("input[type=radio]")
      : selectElement.options;
    const randomIndex = Math.floor(Math.random() * options.length);
    if (isRadio) {
      options[randomIndex].checked = true;
    } else {
      selectElement.selectedIndex = randomIndex;
    }
  }

  setRandomFutureDate(dateElement) {
    const date = new Date();
    date.setDate(date.getDate() + Math.floor(Math.random() * 365) + 1);
    dateElement.valueAsDate = date;
  }
}
