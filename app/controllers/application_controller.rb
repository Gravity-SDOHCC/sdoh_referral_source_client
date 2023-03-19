class ApplicationController < ActionController::Base
  # protect_from_forgery prepend: true
  protect_from_forgery with: :exception
  include ApplicationHelper
  # Not safe to use this in production
  # skip_before_action :verify_authenticity_token

  def require_client
    puts "CHECK CHECK I AM IN require_client. before_action :require_client works."
    if client_connected?
      get_client
      # get_current_patient
      # get_current_practitioner
    else
      flash[:error] = "You are not connected to a FHIR server"
      puts "CHECK CHECK I AM IN require_client. before_action :require_client works. Ready to redirect. FLASH : #{flash.count}"
      redirect_to home_path
    end
  end
end
