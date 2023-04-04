module HealthConcernsHelper
  include SessionHelper

  def fetch_health_concerns
    client = get_client
    search_params = {
      parameters: {
        category: "health-concern",
        subject: patient_id,
        _sort: "-_lastUpdated"
      }
    }

    begin
      response = client.search(FHIR::Condition, search: search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        health_concerns = entries.map do |entry|
          HealthConcern.new(entry.resource)
        end
        # Grouping by clinical status (active, inactive, resolved)
        grp = health_concerns.group_by do |concern|
          concern.clinical_status
        end
        [true, grp]
      else
        [false, "Failed to fetch patient's health concerns. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    rescue StandardError => e
      [false, "Something went wrong. #{e.message}"]
    end
  end
end
