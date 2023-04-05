class TasksController < ApplicationController
  before_action :require_client

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
        supportingInfo: service_req_supporting_info
      )
      sr_result = service_request.create

      # Task referral
      task = FHIR::Task.new(
        meta: task_meta,
        status: params[:status],
        intent: "order",
        code: task_code,
        focus: {reference: "ServiceRequest/#{sr_result.id}"},
        for: service_req_subject,
        authoredOn: Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.%3NZ'),
        requester: task_requester,
        owner: task_owner
      )
      task.create
      flash[:success] = "Task has been created"
    rescue => e
      flash[:error] = "Unable to create task: #{e.message}"
    end
    set_active_tab("action-steps")
    redirect_to dashboard_path
  end

  def update_task

  end

  private
  ### Task Attributes ###
  def task_meta
    {
      "profile": [
        "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForReferralManagement"
      ]
    }
  end

  def task_code
    {
      "coding": [
        {
          "system": "http://hl7.org/fhir/CodeSystem/task-code",
          "code": "fulfill",
          "display": "Fulfill the focal request"
        }
      ]
    }
  end

  def task_requester
    # TODO: Get the practioner role from the server and save it in the session when querying the practioner
    {
      "reference": "PractitionerRole/SDOHCC-PractitionerRoleDrJanWaterExample",
      "display": "Dr Jan Water Family Medicine Physician"
    }
  end

  def task_owner
    {
      "reference": "Organization/#{params[:performer_id]}",
      "display": performer_options.find {|arr| arr[1] == params[:performer_id]}&.first
    }
  end

  ### Service Request Attributes ###
  def service_req_meta
    {
      "profile": [
        "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ServiceRequest"
      ]
    }
  end

  def service_req_category
    [
      {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "410606002",
            "display": "Social service procedure"
          }
        ]
      },
      {
        "coding": [
          {
            "system": "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes",
            "code": params[:category],
            "display": params[:category].titleize
          }
        ]
      }
    ]
  end

  def service_req_code
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": params[:request_code],
          "display": request_options[params[:category]]&.find {|arr| arr[1] == params[:request_code]}&.first
        }
      ]
    }
  end

  def service_req_subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient&.name
    }
  end

  def service_req_reason_reference
    [
      {
        "reference": "Condition/#{params[:condition_ids]}"
      }
    ]
  end

  def service_req_supporting_info
    [
      {
        "reference": "Consent/#{params[:consent]}"
      }
    ]

  end
end
