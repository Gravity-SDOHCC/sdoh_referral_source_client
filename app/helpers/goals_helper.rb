module GoalsHelper
  include SessionHelper

  def fetch_goals
    client = get_client
    search_params = {
      parameters: {
        subject: patient_id,
        _sort: "-_lastUpdated"
      }
    }

    begin
      response = client.search(FHIR::Goal, search: search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        goals = entries.map do |entry|
          Goal.new(entry.resource)
        end

        # Grouping by active and completed
        grp = goals.group_by { |goal| goal.status }
        [true, grp]
      else
        [false, "Failed to fetch patient's goals. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    rescue StandardError => e
      [false, "Something went wrong. #{e.message}"]
    end
  end
end
