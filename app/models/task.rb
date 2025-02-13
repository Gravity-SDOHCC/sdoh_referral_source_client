class Task
  include ModelHelper

  attr_reader :id, :status, :focus, :owner_reference, :owner_name, :outcome, :outcome_type, :fhir_resource, :code

  def initialize(fhir_task, fhir_client: nil)
    @id = fhir_task.id
    @fhir_resource = fhir_task
    remove_client_instances(@fhir_resource)
    @status = fhir_task.status
    @focus = get_focus(fhir_task.focus, fhir_client)
    @owner_reference = fhir_task.owner&.reference
    @owner_name = fhir_task.owner&.display
    @outcome = get_outcome(fhir_task.output&.first, fhir_client)
    @code = get_coding(fhir_task.code&.coding&.first)
  end

  private

  def get_focus(focus, fhir_client)
    return if focus.nil?

    f = focus.reference_id
    fhir_focus = fhir_client.read(FHIR::ServiceRequest, f).resource
    # sometimes for some reason read returns FHIR::Bundle
    fhir_focus = fhir_focus&.entry&.first&.resource if fhir_focus.is_a?(FHIR::Bundle)
    ServiceRequest.new(fhir_focus, fhir_client: fhir_client) if fhir_focus
  end

  def get_outcome(outcome, fhir_client)
    return if outcome.nil?

    # if output is a reference, try to resolve it
    if outcome.valueReference.present?
      type = outcome.valueReference&.reference.split("/").first
      id = outcome.valueReference&.reference.split("/").last

      Rails.logger.info("outcome type:  #{type} id: #{id}")

      case type
      when "Procedure"
        @outcome_type = "Procedure"
        fhir_outcome = fhir_client.read(FHIR::Procedure, id).resource
        Procedure.new(fhir_outcome, fhir_client: fhir_client) if fhir_outcome
      when "QuestionnaireResponse"
        @outcome_type = "QuestionnaireResponse"
        fhir_outcome = fhir_client.read(FHIR::QuestionnaireResponse, id).resource
        QuestionnaireResponse.new(fhir_outcome, fhir_client: fhir_client) if fhir_outcome
      when "DocumentReference"
        @outcome_type = "DocumentReference"
        fhir_outcome = fhir_client.read(FHIR::DocumentReference, id).resource
        DocumentReference.new(fhir_outcome, fhir_client: fhir_client) if fhir_outcome
      else
        nil
      end

    # codes and markdown just returned as strings
    elsif outcome.valueCodeableConcept.present?
      outcome.valueCodeableConcept.coding&.first&.code&.titleize
      @outcome_type = outcome.type&.coding&.first&.code&.titleize
    elsif outcome.valueMarkdown.present?
      outcome.valueMarkdown
      @outcome_type = "markdown"
    end



  end

  def get_coding(coding)
    return if coding.nil?
    coding.display || coding.code
  end
end
