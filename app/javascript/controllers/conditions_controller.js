// app/javascript/controllers/conditions_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "categorySelect",
    "protectiveFactor",
    "icd10Code",
    "icd10Desc",
    "snomedCode",
    "snomedDesc"
  ];

  // SDOHCC-Condition cond-5: when Condition.category includes protective-factor,
  // Condition.code is drawn from the protective factor value set, whichever SDOH
  // domain is also selected. So the checkbox, not the dropdown, keys the code list.
  static PROTECTIVE_FACTOR = "protective-factor";

  connect() {
    this.descriptionOptions = JSON.parse(this.data.get("descriptionOptionsCondition"));
  }

  submit(e) {
    const errorDiv = document.getElementById("conditions-errors");
    errorDiv.style.display = "none";
    errorDiv.textContent = "";
    const hasCategory = this.categorySelectTarget.value.trim() || this.protectiveFactorSelected();
    const hasICD = this.icd10CodeTarget.value.trim() && this.icd10DescTarget.value.trim();
    const hasSNOMED = this.snomedCodeTarget.value.trim() && this.snomedDescTarget.value.trim();
    if( !hasCategory ){
      e.preventDefault();
      errorDiv.style.display = "block";
      errorDiv.textContent = "Select a Category or mark this as a protective factor";
    }
    else if( !hasICD && !hasSNOMED ){
      e.preventDefault();
      errorDiv.style.display = "block";
      errorDiv.textContent = "Select ICD10 and/or SNOMED";
    }
  }

  protectiveFactorSelected() {
    return this.hasProtectiveFactorTarget && this.protectiveFactorTarget.checked;
  }

  handleCategoryChange() {
    this.populateCodeOptions();
  }

  handleProtectiveFactorChange() {
    // category[SDOHCC] is 0..*, so a protective factor may stand on its own.
    this.categorySelectTarget.required = !this.protectiveFactorSelected();
    this.populateCodeOptions();
  }

  populateCodeOptions() {
    const selectedCategory = this.protectiveFactorSelected()
      ? this.constructor.PROTECTIVE_FACTOR
      : this.categorySelectTarget.value;

    if (!selectedCategory || selectedCategory === 'default') {
      this.disableOptions(true);
      this.items = [];
      return;
    }
    this.disableOptions(false);

    const items = this.descriptionOptions[selectedCategory] || [];
    this.items=items;
    items.forEach(item => {
      const display = item[0];
      const code = item[1];
      const isICD10 = /^[A-Za-z]/.test(code);
      if(isICD10) {
        this.icd10CodeTarget.innerHTML+=`<option value="${code}">${code}</option>`;
        this.icd10DescTarget.innerHTML+=`<option value="${display}">${display}</option>`;
      } else {
        this.snomedCodeTarget.innerHTML+=`<option value="${code}">${code}</option>`;
        this.snomedDescTarget.innerHTML+=`<option value="${display}">${display}</option>`;
      }
    });
  }

  disableOptions(e) {
    this.icd10CodeTarget.disabled = e;
    this.icd10DescTarget.disabled = e;
    this.snomedCodeTarget.disabled = e;
    this.snomedDescTarget.disabled = e;

    this.icd10CodeTarget.innerHTML=`<option value="">Select a ICD-10 Code</option>`;
    this.icd10DescTarget.innerHTML=`<option value="">Select a ICD-10 Description</option>`
    this.snomedCodeTarget.innerHTML=`<option value="">Select a SNOMED Code</option>`
    this.snomedDescTarget.innerHTML=`<option value="">Select a SNOMED Description</option>`
  }

  handleCodeChange(e){
    const target = e.target;
    const code = target.value;
    const match = (this.items || []).find(i=>i[1] === code);

    if(target === this.icd10CodeTarget){
      this.icd10DescTarget.value=match ? match[0]: "";
    }
    else if(target === this.snomedCodeTarget){
      this.snomedDescTarget.value=match ? match[0]: "";
    }
  }

  handleDescriptionChange(e){
    const target = e.target;
    const display = target.value;
    const match = (this.items || []).find(i=>i[0] === display);

    if(target === this.icd10DescTarget){
      this.icd10CodeTarget.value=match ? match[1]: "";
    }
    else if(target === this.snomedDescTarget){
      this.snomedCodeTarget.value=match ? match[1]: "";
    }
  }

}
