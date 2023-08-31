class ServiceRequest
  attr_reader :id, :status, :category, :description, :performer_name, :performer_reference, :consent, :goal, :problem, :fhir_resource

  def initialize(fhir_service_request, fhir_client: nil)
    @id = fhir_service_request.id
    @fhir_resource = fhir_service_request
    @status = fhir_service_request.status
    @category = read_category(fhir_service_request.category)
    @description = read_codeable_concept(fhir_service_request.code)
    @performer_name = fhir_service_request.performer&.first&.display
    @performer_reference = fhir_service_request.performer.first&.reference
    @consent = read_reference(fhir_service_request.supportingInfo&.first, FHIR::Consent, Consent, fhir_client)
    @problem = read_reference(fhir_service_request.reasonReference&.first, FHIR::Condition, Condition, fhir_client)
    # TODO: ruby FHIR::ServiceRequest.pertainsToGoal is not defined. find a workaround
    # @goal = read_reference(fhir_service_request.pertainsToGoal&.first, FHIR::Goal, Goal)
  end

  private

  def read_category(category)
    category&.map { |c| read_codeable_concept(c) }&.join(", ")
  end

  def read_codeable_concept(codeable_concept)
    c = codeable_concept&.coding&.first
    c&.display ? c.display : c&.code&.gsub("-", " ")&.titleize
  end

  def read_reference(reference, fhir_klass, klass, fhir_client)
    return unless reference && fhir_client

    id = reference.reference_id
    fhir_resource = fhir_client.read(fhir_klass, id).resource
    # sometimes for some reason read returns FHIR::Bundle
    fhir_resource = fhir_resource&.entry&.first&.resource if fhir_resource.is_a?(FHIR::Bundle)
    if fhir_klass == FHIR::Condition
      klass.new(fhir_resource, fhir_client: fhir_client) if fhir_resource
    else
      klass.new(fhir_resource) if fhir_resource
    end
  rescue => e
    Rails.logger.error(e.full_message)
  end
end
