# Condition model for Health concerns and Problems
class Condition
  attr_reader :id, :clinical_status, :verification_status, :category, :type, :code, :subject_name, :subject_reference,
              :resolution_period, :onset_period, :asserter_name, :asserter_reference, :evidence_reference,
              :evidence_source, :fhir_resource

  def initialize(fhir_condition, fhir_client: nil)
    @id = fhir_condition.id
    @fhir_resource = fhir_condition
    @clinical_status = get_code_from_complex(fhir_condition.clinicalStatus)
    @verification_status = get_code_from_complex(fhir_condition.verificationStatus)
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
      evidence_ref_id = @evidence_reference&.reference_id
      obs = fhir_client.read(FHIR::Observation, evidence_ref_id).resource if evidence_ref_id
      # For some reason, sometimes a read retuns a FHIR::Bundle instead of a FHIR::Observation
      obs = obs&.entry&.first&.resource if obs.is_a?(FHIR::Bundle)
      @evidence_source = Observation.new(obs) if obs
    end
  end

  private

  def get_code_from_complex(codeable_concept)
    codeable_concept&.coding&.first&.code&.downcase
  end

  def get_category_display(category)
    type =
      category
        &.find { |c| c.coding&.first&.system == "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes" }
        &.coding
        &.first
    type&.display || type&.code&.gsub("-", " ")&.titleize
  end

  def get_type(category)
    category
      &.find { |c| c.coding&.first&.system == "http://hl7.org/fhir/us/core/CodeSystem/condition-category" }
      &.coding
      &.first
      &.code
  end

  def get_evidence_references(evidence)
    evidence&.map(&:detail)&.flatten&.map(&:reference)&.join(", ")
  end

  def get_condition_code(code)
    c = code&.coding&.find { |c| c&.system == "http://hl7.org/fhir/sid/icd-10-cm" }
    c&.display ? "#{c.display} (#{c.code})" : c.code
  end
end
