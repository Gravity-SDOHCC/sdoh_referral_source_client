class TasksController < ApplicationController
  before_action :require_client

  # Task.input:AdditionalContent.type, the coding the profile discriminates the
  # slice on.
  #
  # referral_workflow.html says only that "the provider may attach additional
  # content relevant for the care of the individual through the SDOHCC Task
  # resource" - it never names the slice or the code. The binding comes from
  # SDOHCC-TaskForReferralManagement:
  #   input[AdditionalContent].type = $SDOHCC-CodeSystemTemporaryCodes#additional-content
  ADDITIONAL_CONTENT_TYPE = {
    "coding": [
      {
        "system": FhirProfiles::TEMPORARY_CODE_SYSTEM,
        "code": FhirProfiles::ADDITIONAL_CONTENT_CODE,
        "display": FhirProfiles::ADDITIONAL_CONTENT_DISPLAY,
      },
    ],
  }.freeze

  # input[AdditionalContent].value[x] is Reference(Resource) with no
  # targetProfile, so any resource is legal and a bare id is not enough to build
  # a reference from. The picker submits "<ResourceType>/<id>" and both halves
  # are used; only the types this client actually offers are accepted, so no
  # unvalidated parameter is ever interpolated into a reference.
  ADDITIONAL_CONTENT_RESOURCE_TYPES = %w[
    Condition
    Consent
    DocumentReference
    Goal
    Observation
    QuestionnaireResponse
    ServiceRequest
  ].freeze

  def create
    begin
      # Service Request
      service_request = FHIR::ServiceRequest.new(
        meta: service_req_meta,
        status: "active",
        intent: "order",
        category: service_req_category,
        code: service_req_code,
        priority: params[:priority],
        subject: service_req_subject,
        reasonReference: service_req_reason_reference,
        supportingInfo: service_req_supporting_info,
      )

      sr_result = get_client.create(service_request).resource

      # Task referral
      task = FHIR::Task.new(
        meta: task_meta,
        status: params[:status],
        intent: "order",
        code: task_code,
        focus: { reference: "ServiceRequest/#{sr_result.id}" },
        for: service_req_subject,
        authoredOn: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
        requester: task_requester,
        owner: task_owner,
        input: task_input,
      )
      get_client.create(task)

      flash[:success] = "Task has been created"
    rescue => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to create task: #{e.message}"
    end
    Rails.cache.delete(tasks_key)
    set_active_tab("action-steps")
    redirect_to dashboard_path
  end

  def update_task
    begin
      client = get_client
      task = client.read(FHIR::Task, params[:id]).resource
      if task.present?
        task.status = params[:status]
        client.update(task, task.id)

        if params[:status] == "cancelled"
          sr_id = task.focus&.reference_id
          service_request = client.read(FHIR::ServiceRequest, sr_id).resource
          service_request&.status = "revoked"

          client.update(service_request, sr_id)
        end
        flash[:success] = "Task has been marked as #{params[:status]}"
      else
        Rails.logger.error("Unable to update task: task not found")

        flash[:error] = "Unable to update task: task not found"
      end
    rescue => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to update task: #{e.message}"
    end
    Rails.cache.delete(tasks_key)
    set_active_tab("action-steps")
    redirect_to dashboard_path
  end


  def poll_referral_tasks
    saved_tasks = Rails.cache.read(tasks_key) || []
    Rails.cache.delete(tasks_key)
    success, result = fetch_tasks(FhirProfiles::TASK_FOR_REFERRAL_MANAGEMENT)
    if success
      @active_referrals = result["active"] || []
      @completed_referrals = result["completed"] || []
      new_task_list = [@active_referrals, @completed_referrals].flatten
      # check if any active tasks have changed status
      updated_tasks = new_task_list.map do |referral|
        saved_task = saved_tasks.find { |task| task.id == referral.id }
        if saved_task && saved_task.status != referral.status
          referral
        else
          nil
        end
      end.compact
      task_names = updated_tasks.map { |t| t.focus&.description }.join(", ")
      task_status = updated_tasks.map { |t| t.status }.join(", ")
      flash[:success] = "#{task_names} status has been updated to #{task_status}" if updated_tasks.present?
    else
      Rails.logger.error("Unable to poll tasks: #{result}")

      flash[:warning] = result
    end
    render json: {
      active_table: render_to_string(partial: "action_steps/table", locals: { referrals: @active_referrals, type: "active" }),
      completed_table: render_to_string(partial: "action_steps/table", locals: { referrals: @completed_referrals, type: "completed" }),
      flash: flash[:success],
    }
    # render partial: "action_steps/table", locals: { referrals: @active_referrals, type: "active" }
  end

  private

  ### Task Attributes ###
  def task_meta
    {
      "profile": [
        FhirProfiles::TASK_FOR_REFERRAL_MANAGEMENT,
      ],
    }
  end

  def task_code
    {
      "coding": [
        {
          "system": "http://hl7.org/fhir/CodeSystem/task-code",
          "code": "fulfill",
          "display": "Fulfill the focal request",
        },
      ],
    }
  end

  def task_requester
    {
      "reference": "PractitionerRole/#{fetch_and_cache_practitionerRoleId}",
      "display": get_current_practitioner&.name,
    }
  end

  def task_owner
    {
      "reference": "Organization/#{params[:performer_id]}",
      "display": organizations&.find { |org| org&.id == params[:performer_id] }&.name,
    }
  end

   ### Patient Task Attributes ###

    def task_code_for_patient
      {
        "coding": [
          {
            "system": FhirProfiles::TEMPORARY_CODE_SYSTEM,
            "code": "make-contact",  # Example: Replace with the correct code from SDOHCC Task for Patient
            "display": "Make Contact",
          },
        ],
      }
    end

  ### Task.input ###

  # The resources the provider chose to send with the referral, as
  # Task.input:AdditionalContent entries.
  #
  # Returns nil rather than [] when nothing was selected so that the element is
  # omitted from the Task instead of being emitted empty: input is 0..*, and an
  # empty array is not what "no additional content" looks like on the wire.
  def task_input
    entries = Array(params[:additional_content_ids]).filter_map do |value|
      reference = additional_content_reference(value)
      next if reference.blank?

      {
        "type": ADDITIONAL_CONTENT_TYPE,
        "valueReference": { "reference": reference },
      }
    end

    entries.presence
  end

  # "Condition/abc" and nothing else. The type has to be one this client offers
  # and the id has to look like a FHIR id ([A-Za-z0-9-.]{1,64}), so a crafted
  # parameter cannot become part of a reference. Parsing is TaskIoEntry's, which
  # is what reads these references back.
  def additional_content_reference(value)
    resource_type, id = TaskIoEntry.parse_reference(value)
    return unless ADDITIONAL_CONTENT_RESOURCE_TYPES.include?(resource_type)
    return unless id.to_s.match?(/\A[A-Za-z0-9\-.]{1,64}\z/)

    "#{resource_type}/#{id}"
  end

  ### Service Request Attributes ###
  def service_req_meta
    {
      "profile": [
        FhirProfiles::SERVICE_REQUEST,
      ],
    }
  end

  def service_req_category
    [
      {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "410606002",
            "display": "Social service procedure",
          },
        ],
      },
      {
        "coding": [
          {
            "system": FhirProfiles::TEMPORARY_CODE_SYSTEM,
            "code": params[:category],
            "display": params[:category]&.titleize,
          },
        ],
      },
    ]
  end

  def service_req_code
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": params[:request_code],
          "display": request_options[params[:category]]&.find { |arr| arr[1] == params[:request_code] }&.first,
        },
      ],
    }
  end

  def service_req_subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient&.name,
    }
  end

  # The Condition the referral is being made about, when one was chosen.
  #
  # There is not always one - a patient with no problems recorded has an empty
  # Problem list - and "Condition/" is not a reference. A FHIR server rejects
  # any resource that copies it (HAPI-0508 "Invalid resource reference ... Does
  # not contain resource ID"), so the referral target could not complete the
  # referral: its Procedure copies ServiceRequest.reasonReference.
  def service_req_reason_reference
    condition_id = params[:condition_ids].presence
    return if condition_id.blank?

    [
      {
        "reference": "Condition/#{condition_id}",
      },
    ]
  end

  # Same for the Consent: the picker offers "Select Consent", and a referral
  # sent without one must not carry "Consent/".
  def service_req_supporting_info
    consent_id = params[:consent].presence
    return if consent_id.blank?

    [
      {
        "reference": "Consent/#{consent_id}",
      },
    ]
  end
end
