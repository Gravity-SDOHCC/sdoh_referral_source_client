class Procedure
  include ModelHelper

  attr_reader :id, :status, :category, :description, :performed_date, :problem, :fhir_resource

  def initialize(fhir_procedure, fhir_client: nil)
    @id = fhir_procedure.id
    @fhir_resource = fhir_procedure
    remove_client_instances(@fhir_resource)
    @status = fhir_procedure.status
    @category = read_codeable_concept(fhir_procedure.category)
    @description = read_codeable_concept(fhir_procedure.code)
    @performed_date = fhir_procedure.performedDateTime
    @problem = read_reference(fhir_procedure.reasonReference&.first, fhir_client)
  end

  private

  def read_codeable_concept(codeable_concept)
    display = codeable_concept&.coding&.map(&:display)&.join(", ")
    display || codeable_concept&.coding&.map(&:code)&.join(", ")&.gsub("-", " ")&.titleize
  end

  def read_reference(reference, fhir_client)
    id = reference.reference_id

    return nil if fhir_client.nil?

    condition = fhir_client.read(FHIR::Condition, id).resource
    # sometimes for some reason read returns FHIR::Bundle
    condition = condition.entry&.first&.resource if condition.is_a?(FHIR::Bundle)
    Condition.new(condition, fhir_client: fhir_client) if condition
  end
end
