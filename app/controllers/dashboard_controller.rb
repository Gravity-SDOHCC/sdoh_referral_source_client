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
      set_consents
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

  def set_conditions
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

  def set_goals
    success, result = fetch_goals
    if success
      @active_goals = result["active"] || []
      @completed_goals = result["completed"] || []
    else
      flash[:warning] = result
    end
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

  def set_consents
    search_params = {
      parameters: {
        patient: patient_id
      }
    }

    consents = Rails.cache.read("consents_#{patient_id}")
    @consents = consents and return if consents.present?
    begin
      response = @fhir_client.search(FHIR::Consent, search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        @consents = entries.map { |entry| Consent.new(entry.resource) }
        Rails.cache.write("consents_#{patient_id}", @consents, expires_in: 1.hour)
      end
    rescue => e
      Rails.logger.error "Error fetching consents: #{e.message}"
    end
  end
end
