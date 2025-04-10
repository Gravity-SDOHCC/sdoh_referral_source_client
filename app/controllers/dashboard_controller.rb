class DashboardController < ApplicationController
  before_action :require_client, :set_patients, :set_current_practitioner, :get_patient_references, :get_questionnaires, only: [:main]

  # GET /dashboard
  def main
    @active_tab = active_tab
  end

  private

  # Getting all resources associated with the given patient
  def get_patient_references
    if patient_id.present?
      set_personal_characteristics
      set_conditions
      set_goals
      set_tasks
      set_service_requests
    end
  end

  def set_patients
    success, result = fetch_patients
    if success
      @patients = result
    else
      Rails.logger.error("Failed to set patients: #{result}")

      reset_session
      flash[:error] = result
    end
  end

  def set_current_practitioner
    success, result = fetch_practitioner
    if success
      @current_practitioner = result
    else
      Rails.logger.error("Failed to set current practitioner: #{result}")

      reset_session
      clear_cache
      flash[:error] = result
      redirect_to home_path
    end
  end

  def get_questionnaires
    success, result = fetch_questionnaires_bundle
    if success
      @questionnaires = result
      # @questionnaire_options = @questionnaires.map { |q| [q.title || "Untitled Questionnaire", q.full_url] }
      @questionnaire_options = @questionnaires.entry.map { |e| [e.resource.title || "Untitled Questionnaire", e.fullUrl] }
    else
      Rails.logger.error("Failed to get questionnaires: #{result}")
      flash[:warning] = result
    end
  end

  def set_personal_characteristics
    success, result = fetch_personal_characteristics
    if success
      @personal_characteristics = result
    else
      Rails.logger.info("Failed to set personal characteristics #{result}")

      flash[:warning] = result
    end
  end

  def set_conditions
    success, result = fetch_health_concerns
    if success
      @active_problems = result["problem-list-item"]&.dig("active") || []
      @resolved_problems = result["problem-list-item"]&.dig("resolved") || []
      @active_health_concerns = result["health-concern"]&.dig("active") || []
      @resolved_health_concerns = result["health-concern"]&.dig("resolved") || []
    else
      Rails.logger.info("Failed to set conditions: #{result}")

      flash[:warning] = result
    end
  end

  def set_goals
    goals = Rails.cache.read(goals_key) || fetch_goals
    @active_goals = goals["active"] || []
    @completed_goals = goals["completed"] || []
  rescue => e
    Rails.logger.info(e.full_message)

    flash[:warning] = e.message
  end

  def set_tasks
    success, result = fetch_tasks("http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForReferralManagement")
    if success
      @active_referrals = result["active"] || []
      @completed_referrals = result["completed"] || []
    else
      Rails.logger.info("Failed to set referrals: #{result}")

      flash[:warning] = result
    end

    success, result = fetch_tasks("http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-TaskForPatient")
    if success
      @active_patient_tasks = result["active"] || []
      @completed_patient_tasks = result["completed"] || []
    else
      Rails.logger.info("Failed to set referrals: #{result}")

      flash[:warning] = result
    end
  end

  def set_service_requests
    success, result = fetch_service_requests
    if success
      @service_requests = result
    else
      Rails.logger.info("Failed to set service requests: #{result}")

      flash[:warning] = result
    end
  end
end
