module ConditionsHelper
  include SessionHelper

  def save_conditions(conditions)
    Rails.cache.write("conditions_#{patient_id}", conditions, expires_in: 1.hour)
  end

  def fetch_health_concerns
    client = get_client
    search_params = {
      parameters: {
        # category: "health-concern",
        subject: patient_id,
        _sort: "-_lastUpdated"
      }
    }

    begin
      response = client.search(FHIR::Condition, search: search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        conditions = entries.map do |entry|
          Condition.new(entry.resource)
        end

        # Grouping by category(health concerns vs problems) then by clinical status (active, inactive, resolved)
        grp = conditions.group_by do |condition|
          condition.type
        end.transform_values do |values|
          values.group_by do |condition|
            condition.clinical_status
          end
        end

        save_conditions(grp["problem-list-item"]&.dig("active"))
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
