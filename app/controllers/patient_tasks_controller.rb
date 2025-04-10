class PatientTasksController < ApplicationController
  before_action :require_client

  def create

    begin

      task = FHIR::Task.new(

        meta: patient_task_meta,
        intent: "order",
        priority: params[:priority],
        code: {
          coding: [
            {
              system: "http://hl7.org/fhir/uv/sdc/CodeSystem/temp",
              code: "complete-questionnaire",
              display: "Complete Questionnaire"
            }
          ]
        },
        for: subject,
        requester: task_requester,
        owner: subject,

        input: {
          type: {
            coding: [
              {
                system: "http://hl7.org/fhir/uv/sdc/CodeSystem/temp",
                code: "questionnaire",
                display: "Questionnaire"
              }
            ]
          },
          valueCanonical: "#{params[:questionnaire]}"
        },
        status: params[:status],
        
      )
      get_client.create(task)
      flash[:success] = "Task for patient has been created"

    rescue => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to create task: #{e.message}"
    end
    Rails.cache.delete(patient_tasks_key)
    set_active_tab("patient-tasks")
    redirect_to dashboard_path

  end


  def poll_patient_tasks
    saved_tasks = Rails.cache.read(patient_tasks_key) || []
    Rails.cache.delete(patient_tasks_key)
    success, result = fetch_tasks(patient_task_meta[:profile].first)
    if success
      @active_patient_tasks = result["active"] || []
      @completed_patient_tasks= result["completed"] || []
      new_task_list = [@active_patient_tasks, @completed_patient_tasks].flatten
      # check if any active tasks have changed status
      updated_tasks = new_task_list.map do |pt|
        saved_task = saved_tasks.find { |task| task.id == pt.id }
        if saved_task && saved_task.status != pt.status
          pt
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
      active_table: render_to_string(partial: "patient_tasks/table", locals: { tasks: @active_patient_tasks, type: "active" }),
      completed_table: render_to_string(partial: "patient_tasks/table", locals: { tasks: @completed_patient_tasks, type: "completed" }),
      flash: flash[:success],
    }
  end



  def patient_task_meta
    {
      "profile": [
        "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForPatient",
      ],
    }
  end

  def subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient&.name,
    }
  end

  def task_requester
    {
      "reference": "PractitionerRole/#{fetch_and_cache_practitionerRoleId}",
      "display": get_current_practitioner&.name,
    }
  end

end