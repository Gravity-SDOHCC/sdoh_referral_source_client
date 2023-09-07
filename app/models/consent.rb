class Consent
  attr_reader :id, :code, :fhir_resource

  def initialize(fhir_consent)
    @id = fhir_consent.id
    @fhir_resource = fhir_consent
    @fhir_resource.client = nil
    @code = read_codeable_concept(fhir_consent.scope)
  end

  private

  def read_codeable_concept(codeable_concept)
    c = codeable_concept&.coding&.first
    c&.display || c&.code&.gsub("-", " ")&.titleize
  end
end
