class DashboardController < ApplicationController
  before_action :require_client, :set_patient

  def main
    puts "CHECK CHECK I AM IN DashboardController#main. Can I access the client? #{client_connected?}. who is the patient? #{@patient.name}"
    @user_name = "John Doe" # Replace with the actual user name
    @user_type = "Admin" # Replace with the actual user type
  end

  private

  def set_patient
    success, result = fetch_current_patient
    if success
      @patient = result
    else
      clean_session
      flash[:error] = result
      redirect_to home_path
    end
  end
end
