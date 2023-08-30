class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include ApplicationHelper

  def require_client
    if client_connected?
      get_client
    else
      reset_session
      clear_cache
      flash[:error] = "Your session has expired. Plesase connect to a FHIR server"
      redirect_to home_path
    end
  end
end
