class HomeController < ApplicationController
  def index
    if client_connected?
      flash[:notice] = "You are already connected to a FHIR server (#{session[:fhir_server_base_url]})"
      puts "CHECK CHECK I am connected. HomeController#index FLASH : #{flash.count}"
      redirect_to dashboard_path
    else
      clean_session
      puts "CHECK CHECK I am NOT connected. HomeController#index. SESSION[:CLIENT]: #{session[:client] || 'nil'}}"
      @fhir_servers = FhirServer.all
    end
  end

  # POST /connect
  def connect
    base_url = params[:fhir_server_base_url]
    server_name = params[:fhir_server_name]
    @fhir_client = FhirClient.setup_client(base_url)
    # TODO: Refactor this to handle Errno::ECONNREFUSED , took too long to connect, etc. Also if-else not needed.
    begin
      capability_statement = @fhir_client.capability_statement

      if capability_statement.present?
        save_client(@fhir_client)
        puts "CHECK CHECK I am connected. HomeController#connect. SESSION[:CLIENT]: #{session[:client] || 'nil'}}"
        fhir_server = FhirServer.find_or_create_by(base_url: base_url) do |server|
          server.name = server_name
        end
        session[:fhir_server_base_url] = fhir_server.base_url
        flash[:success] = "Successfully connected to #{fhir_server.name}"
        puts "CHECK CHECK I am connected. HomeController#connect FLASH : #{flash.count}"
        redirect_to dashboard_path
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
end
