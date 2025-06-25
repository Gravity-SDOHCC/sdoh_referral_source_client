// app/javascript/controllers/conditions_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "categorySelect",
    "icd10Combined",
    "snomedCombined",
    "icd10Code",
    "icd10Desc",
    "snomedCode",
    "snomedDesc"
  ];

  connect() {
    this.descriptionOptions = JSON.parse(this.data.get("descriptionOptionsCondition"));
  }

  submit(e) {
    const errorDiv = document.getElementById("conditions-errors");
    errorDiv.style.display = "none";
    errorDiv.textContent = "";
    const hasCategory = this.categorySelectTarget.value.trim();
    const hasICD = this.icd10CodeTarget.value.trim() && this.icd10DescTarget.value.trim();
    const hasSNOMED = this.snomedCodeTarget.value.trim() && this.snomedDescTarget.value.trim();
    if( !hasCategory ){
      e.preventDefault();
      errorDiv.style.display = "block";
      errorDiv.textContent = "Select a Category";
    }
    else if( !hasICD && !hasSNOMED ){
      e.preventDefault();
      errorDiv.style.display = "block";
      errorDiv.textContent = "Select either a SNOMED and/or ICD10 from options below";
    }
  }

  handleCategoryChange(e) {
    const selectedCategory = e.target.value;
    if (!selectedCategory || selectedCategory === 'default') {
      this.disableOptions(true);
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
        this.icd10CombinedTarget.innerHTML+=`<option value="${code}">${display} (${code}) [ICD10]</option>`;
      } else {
        this.snomedCodeTarget.innerHTML+=`<option value="${code}">${code}</option>`;
        this.snomedDescTarget.innerHTML+=`<option value="${display}">${display}</option>`;
        this.snomedCombinedTarget.innerHTML+=`<option value="${code}">${display} (${code}) [SNOMED]</option>`;
      }
    });
  }

  disableOptions(e) {
    this.icd10CombinedTarget.disabled = e;
    this.snomedCombinedTarget.disabled = e;
    this.icd10CodeTarget.disabled = e;
    this.icd10DescTarget.disabled = e;
    this.snomedCodeTarget.disabled = e;
    this.snomedDescTarget.disabled = e;

    this.icd10CombinedTarget.innerHTML=`<option value="">Select ICD-10 from options below</option>`;
    this.snomedCombinedTarget.innerHTML=`<option value="">Select SNOMED-CT from options below</option>`
    this.icd10CodeTarget.innerHTML=`<option value="">Select a ICD-10 Code</option>`;
    this.icd10DescTarget.innerHTML=`<option value="">Select a ICD-10 Description</option>`
    this.snomedCodeTarget.innerHTML=`<option value="">Select a SNOMED Code</option>`
    this.snomedDescTarget.innerHTML=`<option value="">Select a SNOMED Description</option>`
  }

  handleOptionChange(e){
    const target = e.target;
    const code = target.value;

    if(target === this.icd10CodeTarget){
      const match = this.items.find(i=>i[1] === code);
      this.icd10DescTarget.value=match ? match[0]: "";
      this.icd10CombinedTarget.value=match ? match[1]: "";
    }
    else if(target === this.icd10DescTarget){
      const match = this.items.find(i=>i[0] === code);
      this.icd10CodeTarget.value=match ? match[1]: "";
      this.icd10CombinedTarget.value=match ? match[1]: "";
    }
    else if(target === this.snomedCodeTarget){
      const match = this.items.find(i=>i[1] === code);
      this.snomedDescTarget.value=match ? match[0]: "";
      this.snomedCombinedTarget.value=match ? match[1]: "";
    }
    else if(target === this.snomedDescTarget){
      const match = this.items.find(i=>i[0] === code);
      this.snomedCodeTarget.value=match ? match[1]: "";
      this.snomedCombinedTarget.value=match ? match[1]: "";
    }
    else if(target === this.icd10CombinedTarget){
      const match = this.items.find(i=>i[1] === code);
      this.icd10DescTarget.value=match ? match[0]: "";
      this.icd10CodeTarget.value=match ? match[1]: "";
    }
    else if(target === this.snomedCombinedTarget){
      const match = this.items.find(i=>i[1] === code);
      this.snomedCodeTarget.value=match ? match[1]: "";
      this.snomedDescTarget.value=match ? match[0]: "";
    }
  }

}
