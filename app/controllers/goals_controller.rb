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

      result = get_client.create(goal).resource

      flash[:success] = "Goal has been created"

      goals = fetch_goals
      new_goal = goals["active"].find { |goal| goal.id == result.id}
      if new_goal.nil?
        goals["active"] << Goal.new(result, fhir_client: get_client)
        save_goals(goals)
      end
    rescue => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to create goal. #{e.message}"
    end
    set_active_tab("goals")
    redirect_to dashboard_path
  end

  def update_goal
    begin
      if @goal
        case params[:field]
        when "completed"
          @goal.fhir_resource.achievementStatus = achievement_status("achieved")
        end

        get_client.update(@goal.fhir_resource, @goal.id)

        flash[:success] = "Goal has been marked as #{params[:status]}"
      else
        Rails.logger.error("Unable to update goal: goal not found")

        flash[:error] = "Unable to update goal: goal not found"
      end
    rescue => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to update goal: #{e.message}"
    end
    set_active_tab("goals")
    Rails.cache.delete(goals_key)
    redirect_to dashboard_path
  end

  def destroy
    begin
      if @goal
        get_client.destroy(FHIR::Goal, @goal.id)
        flash[:success] = "Goal deleted successfully"
        goals = fetch_goals
        removed_goal = goals["active"].find { |goal| goal.id == @goal.id }
        if !removed_goal.nil?
          goals["active"].delete(removed_goal)
          save_goals(goals)
        end
      else
        Rails.logger.error("Unable to delete goal: Goal not found")

        flash[:error] = "Unable to delete goal: Goal not found"
      end
    rescue => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to destroy goal: #{e.message}"
    end
    redirect_to dashboard_path
  end

  private

  def get_goal
    goals = fetch_goals
    @goal = goals["active"].find { |goal| goal.id == params[:id] }
  rescue => e
    Rails.logger.error(e.full_message)
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
          "code": params[:description_code],
          "display": GOAL_DESCRIPTIONS[params[:description_code]],
        },
      ],
    }
  end

  def subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient&.name,
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
