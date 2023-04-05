class ServiceRequest
  attr_reader :id, :status, :category, :description, :performer_name, :performer_reference, :consent, :goal, :problem, :fhir_resource

  def initialize(fhir_service_request)
    @id = fhir_service_request.id
    @fhir_resource = fhir_service_request
    @status = fhir_service_request.status
    @category = read_category(fhir_service_request.category)
    @description = read_codeable_concept(fhir_service_request.code)
    @performer_name = fhir_service_request.performer.first&.display
    @performer_reference = fhir_service_request.performer.first&.reference
    @consent = read_reference(fhir_service_request.supportingInfo&.first, FHIR::Consent, Consent)
    # TODO: ruby FHIR::ServiceRequest.pertainsToGoal is not defined. find a workaround
    # @goal = read_reference(fhir_service_request.pertainsToGoal&.first, FHIR::Goal, Goal)
    @problem = read_reference(fhir_service_request.reasonReference&.first, FHIR::Condition, Condition)
  end

  private

  def read_category(category)
    category.map { |c| read_codeable_concept(c) }.join(", ")
  end

  def read_codeable_concept(codeable_concept)
    c = codeable_concept&.coding&.first
    c&.display ? c&.display : c&.code&.gsub("-", " ")&.titleize
  end

  def read_reference(reference, fhir_klass, klass)
    return unless reference
    id = reference.reference.split("/").last
    fhir_resource = fhir_klass.read(id)
    # sometimes for some reason read returns FHIR::Bundle
    fhir_resource = fhir_resource&.resource&.entry&.first&.resource if fhir_resource.is_a?(FHIR::Bundle)
    klass.new(fhir_resource) if fhir_resource
  end
end
