# Helper constants valueset for Condition resource (health concern/ problem)
module ConditionDefinitionsHelper
  CONDITION_PROFILE = FhirProfiles::CONDITION
  CATEGORY_SDOH_CODE_SYSTEM = FhirProfiles::TEMPORARY_CODE_SYSTEM
  CONDITION_CATEGORY_US_CORE_CODE_SYSTEM = "http://hl7.org/fhir/us/core/CodeSystem/condition-category".freeze
  SNOMED_CODE_SYSTEM = "http://snomed.info/sct".freeze
  ICD_10_CODE_SYSTEM = "http://hl7.org/fhir/sid/icd-10-cm".freeze

  # SDOHCC-Condition slices Condition.category into problem-or-health-concern,
  # screening-assessment and SDOHCC (0..*). SDOH-Con-3 requires at least one
  # category to be the US Core "sdoh" screening-assessment code.
  CATEGORY_SCREENING_ASSESSMENT_CODE_SYSTEM = "http://hl7.org/fhir/us/core/CodeSystem/us-core-category".freeze
  CATEGORY_SDOH = "sdoh".freeze

  # protective-factor is a member of SDOHCC ValueSet SDOH Category, bound to the
  # same repeating category[SDOHCC] slice as the SDOH domains, so it is additive
  # to a domain rather than an alternative to one (SDOHCC Condition, cond-4).
  CATEGORY_PROTECTIVE_FACTOR = "protective-factor".freeze

  # Extensible additional binding on Condition.code that applies when
  # Condition.category includes protective-factor (SDOHCC Condition, cond-5).
  # VSAC "Protective Factors Findings", OID 2.16.840.1.113762.1.4.1247.311.
  PROTECTIVE_FACTORS_VALUE_SET = "http://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1247.311".freeze

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
