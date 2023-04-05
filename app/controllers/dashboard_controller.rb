class DashboardController < ApplicationController
  before_action :require_client, :set_patients, :set_current_practitioner, :get_patient_referrences,

  # GET /dashboard
  def main
    @active_tab = active_tab
  end

  private
  # Getting all resources associated with the given patient
  def get_patient_referrences
    if patient_id.present?
      set_personal_characteristics
      set_health_concerns
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
      Rails.cache.clear
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

  def set_health_concerns
    success, result = fetch_health_concerns
    if success
      @active_problems =  result["problem-list-item"]&.dig("active") || []
      @resolved_problems = result["problem-list-item"]&.dig("resolved") || []
      @active_health_concerns = result["health-concern"]&.dig("active") || []
      @resolved_health_concerns = result["health-concern"]&.dig("resolved") || []
    else
      flash[:warning] = result
    end
  end
end
