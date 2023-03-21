class DashboardController < ApplicationController
  before_action :require_client, :set_patients

  def main
    puts "CHECK CHECK I AM IN DashboardController#main. Can I access the client? #{client_connected?}. who is the patient? #{current_patient.name}"
    @user_name = "John Doe" # Replace with the actual user name
    @user_type = "Admin" # Replace with the actual user type
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
end
