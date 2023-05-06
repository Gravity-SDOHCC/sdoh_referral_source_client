class GoalsController < ApplicationController
  before_action :require_client, :get_goal

  def create
    begin
      goal = FHIR::Goal.new(
        meta: meta,
        lifecycleStatus: "active",
        achievementStatus: achievement_status(params[:achievement_status]),
        category: category,
        description: description,
        subject: subject,
        statusDate: Time.now.utc.strftime("%Y-%m-%d"),
        addresses: addresses,
      )

      goal.create
      flash[:success] = "Goal has been created"
    rescue => e
      flash[:error] = "Unable to create goal. #{e.message}"
    end
    set_active_tab("goals")
    Rails.cache.delete("goals_#{patient_id}")
    redirect_to dashboard_path
  end

  def update_goal
    begin
      if @goal
        case params[:field]
        when "completed"
          @goal.achievementStatus = achievement_status("achieved")
        end
        @goal.update
        flash[:success] = "Goal has been marked as #{params[:status]}"
      else
        flash[:error] = "Unable to update goal: goal not found"
      end
    rescue => e
      flash[:error] = "Unable to update goal: #{e.message}"
    end
    set_active_tab("goals")
    Rails.cache.delete("goals_#{patient_id}")
    redirect_to dashboard_path
  end

  def destroy
    begin
      if @goal
        @goal.destroy
        flash[:success] = "Goal deleted successfully"
      else
        flash[:error] = "Unable to delete goal: Goal not found"
      end
    rescue => e
      flash[:error] = "Unable to destroy goal: #{e.message}"
    end
    redirect_to dashboard_path
  end

  private

  def get_goal
    goals = Rails.cache.read("goals_#{patient_id}")
    @goal = goals.find { |goal| goal.id == params[:id] }&.fhir_resource
  end

  ### Create a new goal ###
  def meta
    {
      "profile": ["http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-Goal"],
    }
  end

  def achievement_status(status)
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/goal-achievement",
          "code": status,
          "display": status&.split("-")&.join(" ")&.titleize,
        },
      ],
    }
  end

  def category
    [
      {
        "coding": [
          {
            "system": "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes",
            "code": params[:category],
            "display": params[:category]&.split("-")&.join(" ")&.titleize,
          },
        ],
      },
    ]
  end

  def description
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": GOAL_DESCRIPTION[params[:category]][:code],
          "display": GOAL_DESCRIPTION[params[:category]][:display],
        },
      ],
    }
  end

  def subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient.name,
    }
  end

  def addresses
    [
      {
        "reference": "Condition/#{params[:condition_id]}",
      },
    ]
  end
end
