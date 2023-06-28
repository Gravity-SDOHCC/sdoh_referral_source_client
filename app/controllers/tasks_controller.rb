class TasksController < ApplicationController
  before_action :require_client
  protect_from_forgery with: :null_session, only: :create

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
      sr_result = service_request.create

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
      )
      task.create
      flash[:success] = "Task has been created"
    rescue => e
      flash[:error] = "Unable to create task: #{e.message}"
    end
    Rails.cache.delete("tasks_#{patient_id}")
    set_active_tab("action-steps")
    redirect_to dashboard_path
  end

  def update_task
    begin
      task = FHIR::Task.read(params[:id])
      if task.present?
        task.status = params[:status]
        task.update

        if params[:status] == "cancelled"
          sr_id = task.focus&.reference&.split("/")&.last
          service_request = FHIR::ServiceRequest.read(sr_id)
          service_request.status = "revoked"
          service_request.update
        end
        flash[:success] = "Task has been marked as #{params[:status]}"
      else
        flash[:error] = "Unable to update task: task not found"
      end
    rescue => e
      flash[:error] = "Unable to update task: #{e.message}"
    end
    Rails.cache.delete("tasks_#{patient_id}")
    set_active_tab("action-steps")
    redirect_to dashboard_path
  end

  def poll_tasks
    saved_tasks = Rails.cache.read("tasks_#{patient_id}") || []
    Rails.cache.delete("tasks_#{patient_id}")
    success, result = fetch_tasks
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
      task_names = updated_tasks.map { |t| t.focus.description }.join(", ")
      task_status = updated_tasks.map { |t| t.status }.join(", ")
      flash[:success] = "#{task_names} status has been updated to #{task_status}" if updated_tasks.present?
    else
      # Rails.logger.warn { 'message' => 'Unable to fetch tasks for update', 'result' => result }
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
        "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForReferralManagement",
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
      "display": organizations.find { |org| org.id == params[:performer_id] }&.name,
    }
  end

  ### Service Request Attributes ###
  def service_req_meta
    {
      "profile": [
        "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ServiceRequest",
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
            "system": "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes",
            "code": params[:category],
            "display": params[:category].titleize,
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
    save_patient_id(params[:patient_id]) if patient_id.nil?

    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient&.name,
    }
  end

  def service_req_reason_reference
    [
      {
        "reference": "Condition/#{params[:condition_ids]}",
      },
    ]
  end

  def service_req_supporting_info
    [
      {
        "reference": "Consent/#{params[:consent]}",
      },
    ]
  end
end
