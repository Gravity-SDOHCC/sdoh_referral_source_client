class DashboardController < ApplicationController
  before_action :require_client, :set_patients, :set_current_practitioner, :set_personal_characteristics

  def main
    puts "CHECK CHECK I AM IN DashboardController#main. Can I access the client? #{client_connected?}. who is the patient? #{current_patient.name}"
  end

  private

  def set_patients
    success, result = fetch_patients
    if success
      @patients = result
    else
      clean_session
      flash[:error] = result
      redirect_to home_path
    end
  end

  def set_current_practitioner
    success, result = fetch_practitioner
    if success
      @current_practitioner = result
    else
      clean_session
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
end
