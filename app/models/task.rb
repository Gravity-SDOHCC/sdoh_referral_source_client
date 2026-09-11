class Task
  include ModelHelper

  attr_reader :id, :status, :focus, :owner_reference, :owner_name, :outputs, :inputs, :fhir_resource, :code

  def initialize(fhir_task, fhir_client: nil)
    @id = fhir_task.id
    @fhir_resource = fhir_task
    remove_client_instances(@fhir_resource)
    @status = fhir_task.status
    @focus = get_focus(fhir_task.focus, fhir_client)
    @owner_reference = fhir_task.owner&.reference
    @owner_name = fhir_task.owner&.display
    @outputs = build_io_entries(fhir_task.output, fhir_client)
    # Inputs are parsed but their references are deliberately not resolved: no
    # view renders Task.input yet, and resolving one would cost a server read
    # per entry on every dashboard refresh. Pass the client here when one does.
    @inputs = build_io_entries(fhir_task.input, nil)
    @code = get_coding(fhir_task.code&.coding&.first)
  end

  # Task.output entries under the resulting-activity code: what was done.
  def performed_activity_outputs
    outputs.select(&:performed_activity?)
  end

  # Task.output entries under the additional-content code: enrollment status,
  # assessments, goals, conditions and the like.
  def additional_content_outputs
    outputs.select(&:additional_content?)
  end

  # Task.input entries under the additional-content code.
  def additional_content_inputs
    inputs.select(&:additional_content?)
  end

  # The Enrollment Status Observation this referral was closed with, if there
  # is one.
  #
  # enrollment.html, referral-triggered workflow: "To close the loop on the
  # referral, the CBO updates the Task, pointing to the Enrollment Status
  # Observation in Task.output." It arrives in the AdditionalContent slice,
  # which is shared with assessments, goals and conditions, so the Observation's
  # own category is what identifies it.
  def enrollment_status
    additional_content_outputs
      .map(&:resource)
      .compact
      .find { |resource| resource.is_a?(Observation) && resource.program_enrollment? }
  end

  # The first resulting-activity output. Kept so callers written against the
  # single-outcome API keep working while they move to #outputs.
  def outcome
    performed_activity_outputs.first&.then { |entry| entry.resource || entry.value }
  end

  def outcome_type
    performed_activity_outputs.first&.display_type
  end

  private

  def build_io_entries(entries, fhir_client)
    Array(entries).filter_map { |entry| TaskIoEntry.build(entry, fhir_client) }
  end

  def get_focus(focus, fhir_client)
    return if focus.nil?

    f = focus.reference_id
    fhir_focus = fhir_client.read(FHIR::ServiceRequest, f).resource
    # sometimes for some reason read returns FHIR::Bundle
    fhir_focus = fhir_focus&.entry&.first&.resource if fhir_focus.is_a?(FHIR::Bundle)
    ServiceRequest.new(fhir_focus, fhir_client: fhir_client) if fhir_focus
  end

  def get_coding(coding)
    return if coding.nil?
    coding.display || coding.code
  end
end
