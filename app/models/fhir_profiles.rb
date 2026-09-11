# Canonical URLs for the FHIR artifacts this client reads and writes.
#
# Every profile, extension and temporary-code-system URL used anywhere in the
# application is declared here so that a spec change is a one-line edit and so
# that no two call sites can disagree about a canonical URL. Nothing outside
# this module should carry one as a string literal.
#
# SDOH artifacts are from HL7 FHIR Implementation Guide "Social Determinants of
# Health Clinical Care" (hl7.fhir.us.sdoh-clinicalcare), STU 3 continuous build.
module FhirProfiles
  # --- SDOH Clinical Care profiles ---

  # SDOHCC Task For Referral Management
  TASK_FOR_REFERRAL_MANAGEMENT = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForReferralManagement".freeze
  # SDOHCC Task For Patient
  TASK_FOR_PATIENT = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForPatient".freeze
  # SDOHCC ServiceRequest
  SERVICE_REQUEST = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ServiceRequest".freeze
  # SDOHCC Procedure
  PROCEDURE = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-Procedure".freeze
  # SDOHCC Goal
  GOAL = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-Goal".freeze
  # SDOHCC Condition
  CONDITION = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-Condition".freeze

  # SDOHCC Observation Race OMB
  OBSERVATION_RACE_OMB = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ObservationRaceOMB".freeze
  # SDOHCC Observation Ethnicity OMB
  OBSERVATION_ETHNICITY_OMB = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ObservationEthnicityOMB".freeze
  # SDOHCC Observation Gender Identity
  OBSERVATION_GENDER_IDENTITY = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ObservationGenderIdentity".freeze
  # SDOHCC Observation Recorded Sex Gender
  OBSERVATION_RECORDED_SEX_GENDER = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ObservationRecordedSexGender".freeze
  # SDOHCC Observation Sexual Orientation
  OBSERVATION_SEXUAL_ORIENTATION = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ObservationSexualOrientation".freeze
  # SDOHCC Observation Personal Pronouns
  OBSERVATION_PERSONAL_PRONOUNS = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ObservationPersonalPronouns".freeze

  # --- SDOH Clinical Care extensions ---

  # SDOHCC Extension Healthcare Service Capacity Status
  CAPACITY_STATUS_EXTENSION = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ExtensionHealthcareServiceCapacityStatus".freeze

  # --- SDOH Clinical Care code system ---

  # SDOHCC CodeSystem Temporary Codes
  TEMPORARY_CODE_SYSTEM = "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes".freeze

  # The two SDOHCC-CodeSystemTemporaryCodes concepts that discriminate the
  # Task.input and Task.output slices in SDOHCC-TaskForReferralManagement.
  ADDITIONAL_CONTENT_CODE = "additional-content".freeze
  ADDITIONAL_CONTENT_DISPLAY = "Additional Content".freeze
  RESULTING_ACTIVITY_CODE = "resulting-activity".freeze
  RESULTING_ACTIVITY_DISPLAY = "Resulting Activity".freeze

  # SDOHCC-CodeSystemTemporaryCodes concept that SDOHCC-ObservationProgramEnrollmentStatus
  # fixes category[enrollment] to. Task.output:AdditionalContent carries
  # assessments, screening responses, goals, conditions and questionnaire
  # responses as well as enrollment status, so the category is what identifies
  # an enrollment status Observation among them.
  PROGRAM_ENROLLMENT_CATEGORY_CODE = "program-enrollment".freeze

  # --- US Core extensions (hl7.fhir.us.core) ---

  # US Core Race Extension
  US_CORE_RACE_EXTENSION = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race".freeze
  # US Core Ethnicity Extension
  US_CORE_ETHNICITY_EXTENSION = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity".freeze
  # US Core Birth Sex Extension
  US_CORE_BIRTHSEX_EXTENSION = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex".freeze
end
