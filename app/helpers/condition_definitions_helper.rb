# Helper constants valueset for Condition resource (health concern/ problem)
module ConditionDefinitionsHelper
  CONDITION_PROFILE = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-Condition".freeze
  CATEGORY_SDOH_CODE_SYSTEM = "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes".freeze
  CONDITION_CATEGORY_US_CORE_CODE_SYSTEM = "http://hl7.org/fhir/us/core/CodeSystem/condition-category".freeze
  SNOMED_CODE_SYSTEM = "http://snomed.info/sct".freeze
  ICD_10_CODE_SYSTEM = "http://hl7.org/fhir/sid/icd-10-cm".freeze

  CONDITION_CATEGORY = [
    {
      code: "sdoh-category-unspecified",
      display: "SDOH Category Unspecified"
    },
    {
      code: "food-insecurity",
      display: "Food Insecurity"
    },
    {
      code: "housing-instability",
      display: "Housing Instability"
    },
    {
      code: "homelessness",
      display: "Homelessness"
    },
    {
      code: "inadequate-housing",
      display: "Inadequate Housing"
    },
    {
      code: "transportation-insecurity",
      display: "Transportation Insecurity"
    },
    {
      code: "financial-insecurity",
      display: "Financial Insecurity"
    },
    {
      code: "material-hardship",
      display: "Material Hardship"
    },
    {
      code: "educational-attainment",
      display: "Educational Attainment"
    },
    {
      code: "employment-status",
      display: "Employment Status"
    },
    {
      code: "veteran-status",
      display: "Veteran Status"
    },
    {
      code: "stress",
      display: "Stress"
    },
    {
      code: "social-connection",
      display: "Social Connection"
    },
    {
      code: "intimate-partner-violence",
      display: "Intimate Partner Violence"
    },
    {
      code: "elder-abuse",
      display: "Elder Abuse"
    },
    {
      code: "personal-health-literacy",
      display: "Personal Health Literacy"
    },
    {
      code: "health-insurance-coverage-status",
      display: "Health Insurance Coverage Status"
    },
    {
      code: "medical-cost-burden",
      display: "Medical Cost Burden"
    },
    {
      code: "digital-literacy",
      display: "Digital Literacy"
    },
    {
      code: "digital-access",
      display: "Digital Access"
    },
    {
      code: "utility-insecurity",
      display: "Utility Insecurity"
    },
    {
      code: "incarceration-status",
      display: "Incarceration Status"
    },
    {
      code: "language-access",
      display: "Language Access"
    }
  ]

end
