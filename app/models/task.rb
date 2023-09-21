class Task
  include ModelHelper

  attr_reader :id, :status, :focus, :owner_reference, :owner_name, :outcome, :outcome_type, :fhir_resource

  def initialize(fhir_task, fhir_client: nil)
    @id = fhir_task.id
    @fhir_resource = fhir_task
    remove_client_instances(@fhir_resource)
    @status = fhir_task.status
    @focus = get_focus(fhir_task.focus, fhir_client)
    @owner_reference = fhir_task.owner&.reference
    @owner_name = fhir_task.owner&.display
    @outcome = get_outcome(fhir_task.output&.first, fhir_client)
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

    @outcome_type = outcome.type&.coding&.first&.code&.titleize
    id = outcome.valueReference&.reference.split("/").last
    fhir_outcome = fhir_client.read(FHIR::Procedure, id).resource
    # sometimes for some reason read returns FHIR::Bundle
    fhir_outcome = fhir_outcome&.entry&.first&.resource if fhir_outcome.is_a?(FHIR::Bundle)
    Procedure.new(fhir_outcome, fhir_client: fhir_client) if fhir_outcome
  end
end
