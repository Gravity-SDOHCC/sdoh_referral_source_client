class Task
  attr_reader :id, :status, :focus, :owner_reference, :owner_name, :outcome, :outcome_type, :fhir_resource

  def initialize(fhir_task)
    @id = fhir_task.id
    @fhir_resource = fhir_task
    @status = fhir_task.status
    @focus = get_focus(fhir_task.focus)
    @owner_reference = fhir_task.owner&.reference
    @owner_name = fhir_task.owner&.display
    @outcome = get_outcome(fhir_task.output&.first)
  end

  private

  def get_focus(focus)
    f = focus.reference.split("/").last
    fhir_focus = FHIR::ServiceRequest.read(f)
    # sometimes for some reason read returns FHIR::Bundle
    fhir_focus = fhir_focus&.resource&.entry&.first&.resource if fhir_focus.is_a?(FHIR::Bundle)
    ServiceRequest.new(fhir_focus) if fhir_focus
  end

  def get_outcome(outcome)
    return if outcome.nil?
    @outcome_type = outcome.type&.coding&.first&.code&.titleize
    id = outcome.valueReference&.reference.split("/").last
    fhir_outcome = FHIR::Procedure.read(id)
    # sometimes for some reason read returns FHIR::Bundle
    fhir_outcome = fhir_outcome&.resource&.entry&.first&.resource if fhir_outcome.is_a?(FHIR::Bundle)
    Procedure.new(fhir_outcome) if fhir_outcome
  end
end
