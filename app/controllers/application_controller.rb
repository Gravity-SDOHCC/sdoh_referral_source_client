class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper

  def require_client
    if client_connected?
      get_client
    else
      flash[:error] = "You are not connected to a FHIR server"
      redirect_to home_path
    end
  end
end
