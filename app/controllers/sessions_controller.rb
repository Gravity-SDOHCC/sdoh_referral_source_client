class SessionsController < ApplicationController
  before_action :require_client, except: %i[index create]
  # Get /home
  def index
    if client_connected?
      flash[:notice] = "You are already connected to a FHIR server (#{get_server_base_url})"
      redirect_to dashboard_path
    else
      @fhir_servers = FhirServer.all
    end
  end

  # POST /connect
  def create
    base_url = params[:fhir_server_base_url]
    server_name = params[:fhir_server_name]
    @fhir_client = FhirClient.setup_client(base_url)
    # TODO: Refactor this to handle Errno::ECONNREFUSED , took too long to connect, etc. Also if-else not needed.
    begin
      capability_statement = @fhir_client.capability_statement

      if capability_statement.present?
        save_client(@fhir_client)
        fhir_server = FhirServer.find_or_create_by(base_url: base_url) do |server|
          server.name = server_name
        end
        save_server_base_url(fhir_server.base_url)

        flash[:success] = "Successfully connected to #{fhir_server.name}"
        redirect_to select_test_practitioner_path
      else
        flash[:error] = "Failed to connect to the provided server, verify the URL provided is correct."
        redirect_to home_path
      end
    rescue StandardError => e
      puts "Error happened:#{e.class} => #{e.message}"
      flash[:error] = "Failed to connect to the provided server, verify the URL provided is correct. Error: #{e.message}"
      redirect_to home_path
    end
  end

  # Get /select_test_practitioner
  def select_test_practitioner
    @practitioners = fetch_and_cache_practitioners
    if @practitioners.blank?
      reset_session
      clear_cache
      flash[:warning] = "There are no providers on the server. You need a test provider to see patients data."
      redirect_to root_path
    end
  rescue => e
    reset_session
    clear_cache
    flash[:error] = e.message
    redirect_to root_path
  end

  # Post /set_current_practitioner
  def set_current_practitioner
    save_practitioner_id(params[:provider_id])
    flash[:success] = "successfully signed in!"
    redirect_to dashboard_path
  end

  # delete /disconnect
  def destroy
    reset_session
    clear_cache
    flash[:success] = "Successfully disconnected from the FHIR server"
    redirect_to root_path
  end
end
