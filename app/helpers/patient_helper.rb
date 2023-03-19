module PatientHelper
  include SessionHelper

  def fetch_current_patient
    current_patient = get_current_patient
    if current_patient
      return [true, current_patient]
    end

    client = get_client

    begin
      response = client.read(FHIR::Patient, patient_id)

      if response.response[:code] == 200
        patient = Patient.new(response.resource.entry.map(&:resource).first)
        return [false, "No patient found"] unless patient
        save_patient(patient)
        [true, patient]
      else
        [false, "Failed to fetch patient, please retry. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check the FHIR server's URL #{get_server_base_url} and try again. #{e.message}"]
    # rescue Rack::Timeout::RequestTimeoutException => e
    #   [false, "Request timeout. Please try again later. #{e.message}"]
    end

  end
end
