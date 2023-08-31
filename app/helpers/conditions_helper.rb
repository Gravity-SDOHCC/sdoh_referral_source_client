module ConditionsHelper
  include SessionHelper

  def save_conditions(conditions)
    Rails.cache.write(conditions_key, conditions, expires_in: 1.hour)
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
          Condition.new(entry.resource, fhir_client: client)
        end

        # Grouping by category(health concerns vs problems) then by clinical status (active, inactive, resolved)
        grp =
          conditions
            .group_by(&:type)
            .transform_values { |values| values.group_by(&:clinical_status) }

        save_conditions(grp["problem-list-item"]&.dig("active"))
        [true, grp]
      else
        Rails.logger.error("Failed to fetch patient's health concerns. Status: #{response.response[:code]} - #{response.response[:body]}")

        [false, "Failed to fetch patient's health concerns. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      Rails.logger.error(e.full_message)

      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    rescue StandardError => e
      Rails.logger.error(e.full_message)

      [false, "Something went wrong. #{e.message}"]
    end
  end
end
