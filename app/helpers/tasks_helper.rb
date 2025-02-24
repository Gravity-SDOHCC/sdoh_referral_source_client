module TasksHelper
  include SessionHelper

  def save_tasks(tasks)
    Rails.cache.write(tasks_key, tasks, expires_in: 30.minutes)
  end

  def fetch_tasks(profile)
    client = get_client
    search_params = {
      parameters: {
        subject: patient_id,
        _profile: profile,
        requester: "PractitionerRole/#{fetch_and_cache_practitionerRoleId}",
        _sort: "-_lastUpdated",
      },
    }

    begin
      response = client.search(FHIR::Task, search: search_params)
      if response.response[:code] == 200
        entries = response.resource.entry
        tasks = entries.map do |entry|
          Task.new(entry.resource, fhir_client: client)
        end

        grp = { "active" => [], "completed" => [] }
        tasks.each do |task|
          grp["active"] << task if (task.status != "completed" && task.status != "cancelled" && task.status != "rejected")
          grp["completed"] << task if task.status == "completed"
        end
        save_tasks([grp["active"], grp["completed"]].flatten)
        [true, grp]
      else
        Rails.logger.error("Failed to fetch tasks. Status: #{response.response[:code]} - #{response.response[:body]}")

        [false, "Failed to fetch tasks. Status: #{response.response[:code]} - #{response.response[:body]}"]
      end
    rescue Errno::ECONNREFUSED => e
      Rails.logger.error(e.full_message)

      [false, "Connection refused. Please check FHIR server's URL #{get_server_base_url} is up and try again. #{e.message}"]
    rescue StandardError => e
      Rails.logger.error(e.full_message)

      [false, "Something went wrong. #{e.message}"]
    end
  end

  def category_options
    [
      ["Food Insecurity", "food-insecurity"],
      ["Housing Instability", "housing-instability"],
      ["Transportation Insecurity", "transportation-insecurity"],
    ]
  end

  def request_options
    {
      "food-insecurity" => [
        ["Assessment of health and social care needs", "710824005"],
        ["Assessment of nutritional status", "1759002"],
        ["Counseling about nutrition", "441041000124100"],
        ["Meals on wheels provision education", "385767005"],
        ["Nutrition education", "61310001"],
        ["Patient referral to dietitian", "103699006"],
        ["Provision of food", "710925007"],
        ["Referral to community meals service", "713109004"],
        ["Referral to social worker", "308440001"],
      ],
      "housing-instability" => [
        ["Housing assessment", "225340009"],
        ["Referral to housing service", "710911006"],
      ],
      "transportation-insecurity" => [
        ["Education about benefits enrollment assistance program (procedure)", "464301000124106"],
        ["Coordination of care plan (procedure)", "711069006"],
        ["Referral to Community Action Agency program (procedure)", "462481000124102"],
        ["Assessment of health and social care needs (procedure)", "710824005"],
        ["Coordination of care team (procedure)", "464611000124102"],
        ["Education about Community Action Agency program (procedure)", "464311000124109"],
        ["Education about community resource network program (procedure)", "464291000124105"],
        ["Referral to community resource network program (procedure)", "464161000124109"],
        ["Referral to community health worker (procedure)", "464131000124100"],
        ["Referral to care navigator (procedure)", "464021000124104"],
        ["Referral to care manager (procedure)", "464011000124107"],
        ["Referral to benefits enrollment assistance program (procedure)", "462491000124104"],
        ["Referral to social worker (procedure)", "308440001"],
        ["Referral to case manager (procedure)", "464001000124109"],
        ["Transportation request (procedure)", "428632005"],
        ["Transportation case management (procedure)", "410365006"],
      ],
    }
  end

  def condition_options
    map = []
    conditions = Rails.cache.read(conditions_key) || []
    conditions.each do |condition|
      map << [condition.code, condition.id]
    end
    map
  end
end
