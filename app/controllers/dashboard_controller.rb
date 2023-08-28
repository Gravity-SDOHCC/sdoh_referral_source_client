class DashboardController < ApplicationController
  before_action :require_client, :set_patients, :set_current_practitioner, :get_patient_referrences

  # GET /dashboard
  def main
    @active_tab = active_tab
  end

  private

  # Getting all resources associated with the given patient
  def get_patient_referrences
    if patient_id.present?
      set_personal_characteristics
      set_conditions
      set_goals
      set_referrals
      set_service_requests
    end
  end

  def set_patients
    success, result = fetch_patients
    if success
      @patients = result
    else
      reset_session
      flash[:error] = result
    end
  end

  def set_current_practitioner
    success, result = fetch_practitioner
    if success
      @current_practitioner = result
    else
      reset_session
      clear_cache
      flash[:error] = result
      redirect_to home_path
    end
  end

  def set_personal_characteristics
    success, result = fetch_personal_characteristics
    if success
      @personal_characteristics = result
    else
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
      flash[:warning] = result
    end
  end

  def set_goals
    goals = Rails.cache.read(goals_key) || fetch_goals
    @active_goals = goals["active"] || []
    @completed_goals = goals["completed"] || []
  rescue => e
    flash[:warning] = e.message
  end

  def set_referrals
    success, result = fetch_tasks
    if success
      @active_referrals = result["active"] || []
      @completed_referrals = result["completed"] || []
    else
      flash[:warning] = result
    end
  end

  def set_service_requests
    success, result = fetch_service_requests
    if success
      @service_requests = result
    else
      flash[:warning] = result
    end
  end
end
