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
    "supportingResources",
    "submitButton",
    "capacityBadge",
    "blockedAlert",
    "waitlistAlert",
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
    if (!this.validateSupportingResources()) return;

    const formElement = document.getElementById("task-form");
    formElement.submit(); // Manually submit the form
  }

  // Task.input is 0..*, so attaching nothing is valid. An option that is not
  // "<ResourceType>/<id>" is not: value[x] is Reference(Resource) with no
  // targetProfile, and a value missing its resource type cannot be turned into
  // a reference on the server side either.
  validateSupportingResources() {
    if (!this.hasSupportingResourcesTarget) return true;

    const target = this.supportingResourcesTarget;
    const malformed = Array.from(target.selectedOptions)
      .map(option => option.value)
      .filter(value => value !== "")
      .filter(value => !/^[A-Z][A-Za-z]+\/[A-Za-z0-9.-]{1,64}$/.test(value));

    if (malformed.length === 0) {
      target.setCustomValidity("");
      return true;
    }

    target.setCustomValidity(
      `Cannot attach ${malformed.join(", ")}: expected "ResourceType/id".`
    );
    target.reportValidity();
    return false;
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

  // The demo auto-fill deliberately leaves the additional-content picker alone.
  // Attaching a patient's clinical record to a referral is the provider's
  // decision, and a random selection would send whatever happened to be first
  // in the list.
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

  async checkCapacity() {
    const orgId = this.performerTarget.value
    if (!orgId) return

    let capacity = "unknown"
    try {
      const data = await fetch(`/organizations/${orgId}/check_capacity`).then(r => r.json())
      capacity = data.capacity
    } catch (err) {
      console.error("Capacity check failed", err)
    }

    this.capacityBadgeTarget.classList.remove("d-none", "bg-success", "bg-danger", "bg-warning", "bg-info", "bg-secondary")
    this.blockedAlertTarget.classList.add("d-none")
    this.waitlistAlertTarget.classList.add("d-none")
    this.submitButtonTarget.disabled = false

    if (capacity === "at-capacity") {
      this.capacityBadgeTarget.textContent = "At Capacity"
      this.capacityBadgeTarget.classList.add("bg-danger")
      this.blockedAlertTarget.classList.remove("d-none")
      this.submitButtonTarget.disabled = true
    } else if (capacity === "has-waitlist") {
      this.capacityBadgeTarget.textContent = "Has Waitlist"
      this.capacityBadgeTarget.classList.add("bg-warning")
      this.waitlistAlertTarget.classList.remove("d-none")
      this.submitButtonTarget.disabled = true
    } else if (capacity === "available") {
      this.capacityBadgeTarget.textContent = "Capacity Available"
      this.capacityBadgeTarget.classList.add("bg-success")
    } else if (capacity === "assessment-required") {
      this.capacityBadgeTarget.textContent = "Assessment Required"
      this.capacityBadgeTarget.classList.add("bg-info")
    } else {
      this.capacityBadgeTarget.textContent = "Capacity Unknown"
      this.capacityBadgeTarget.classList.add("bg-secondary")
    }
  }

  proceedWaitlist() {
    this.waitlistAlertTarget.classList.add("d-none")
    this.submitButtonTarget.disabled = false
  }

  cancelWaitlist() {
    this.waitlistAlertTarget.classList.add("d-none")
    this.performerTarget.value = ""
    this.capacityBadgeTarget.classList.add("d-none")
  }
}
