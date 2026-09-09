# Condition model for Health concerns and Problems
class Condition
  include ModelHelper

  SDOH_CATEGORY_CODE_SYSTEM = "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes".freeze
  US_CORE_CONDITION_CATEGORY_CODE_SYSTEM = "http://hl7.org/fhir/us/core/CodeSystem/condition-category".freeze
  PROTECTIVE_FACTOR_CATEGORY = "protective-factor".freeze

  attr_reader :id, :clinical_status, :verification_status, :category, :type, :code, :subject_name, :subject_reference,
              :resolution_period, :onset_period, :asserter_name, :asserter_reference, :evidence_reference,
              :evidence_source, :fhir_resource

  def initialize(fhir_condition, fhir_client: nil)
    @id = fhir_condition.id
    @fhir_resource = fhir_condition
    remove_client_instances(@fhir_resource)
    @clinical_status = get_code_from_complex(fhir_condition.clinicalStatus)
    @verification_status = get_code_from_complex(fhir_condition.verificationStatus)
    @sdoh_category_codes = get_sdoh_category_codes(fhir_condition.category)
    @category = get_category_display(fhir_condition.category)
    @type = get_type(fhir_condition.category) # health-concern or problem-list-item
    @code = get_condition_code(fhir_condition.code)
    @subject_name = fhir_condition.subject&.display
    @subject_reference = fhir_condition.subject&.reference
    @onset_period = fhir_condition.onsetPeriod&.start&.to_time
    @resolution_period = fhir_condition.abatementPeriod&.start&.to_time || fhir_condition.abatementDateTime&.to_time
    @asserter_name = fhir_condition.asserter&.display
    @asserter_reference = fhir_condition.asserter&.reference
    @evidence_reference = get_evidence_references(fhir_condition.evidence)

    if fhir_client.present?
      evidence_ref_id = @evidence_reference&.split("/")&.last

      obs = fhir_client.read(FHIR::Observation, evidence_ref_id).resource if evidence_ref_id
      # For some reason, sometimes a read retuns a FHIR::Bundle instead of a FHIR::Observation
      obs = obs&.entry&.first&.resource if obs.is_a?(FHIR::Bundle)
      @evidence_source = Observation.new(obs) if obs
    end
  end

  # category[SDOHCC] is 0..* on SDOHCC-Condition, so protective-factor sits
  # alongside the SDOH domain rather than replacing it (cond-4).
  def protective_factor?
    @sdoh_category_codes.include?(PROTECTIVE_FACTOR_CATEGORY)
  end

  private

  def get_code_from_complex(codeable_concept)
    codeable_concept&.coding&.first&.code&.downcase
  end

  def sdoh_categories(category)
    category
      &.select { |c| c.coding&.first&.system == SDOH_CATEGORY_CODE_SYSTEM }
      &.map { |c| c.coding&.first }
      &.compact || []
  end

  def get_sdoh_category_codes(category)
    sdoh_categories(category).map(&:code).compact
  end

  # A condition can carry several category[SDOHCC] repeats, so show all of the
  # domains rather than only the first. protective-factor is excluded here and
  # rendered as its own badge by conditions/_table.
  def get_category_display(category)
    displays =
      sdoh_categories(category)
        .reject { |coding| coding.code == PROTECTIVE_FACTOR_CATEGORY }
        .map { |coding| coding.display.presence || coding.code&.gsub("-", " ")&.titleize }
        .compact
    displays.join(", ").presence
  end

  def get_type(category)
    category
      &.find { |c| c.coding&.first&.system == US_CORE_CONDITION_CATEGORY_CODE_SYSTEM }
      &.coding
      &.first
      &.code
  end

  def get_evidence_references(evidence)
    evidence&.map(&:detail)&.flatten&.map(&:reference)&.join(", ")
  end

  def get_condition_code(code)
    c = code&.coding&.find { |c| c&.system == "http://hl7.org/fhir/sid/icd-10-cm" || c&.system == "http://snomed.info/sct"}
    c&.display ? "#{c.display} (#{c.code})" : c.code
  end
end
