module PatientHelper
  include SessionHelper

  def fetch_patients
    patients = get_patients
    if patients
      return [true, patients]
    end

    client = get_client
    begin
      response = client.read_feed(FHIR::Patient)
      if response.response[:code] == 200
        entries = response.resource.entry
        patients = entries.map do |entry|
                    Patient.new(entry.resource)
                  end
        save_patients(patients)
        [true, patients]
      else
        [false, "Failed to fetch patient list, please retry. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    # rescue Rack::Timeout::RequestTimeoutException => e
    #   [false, "Request timeout. Please try again later. #{e.message}"]
    end
  end

  def current_patient
    @current_patient = get_patients&.find { |patient| patient.id == patient_id }
  end
end
