module GoalsHelper
  include SessionHelper

  def save_goals(goals)
    Rails.cache.write(goals_key, goals, expires_in: 1.minute)
  end

  def fetch_goals
    response = get_client.search(FHIR::Goal, search: { parameters: { subject: patient_id, _sort: "-_lastUpdated" }})
    if response.is_a?(FHIR::Bundle)
      entries = response.entry.map(&:resource)
      goals = entries.map { |entry| Goal.new(entry) }
      grp = {"active" => [], "completed" => []}
      goals.each { |goal| goal.achievement_status != "Achieved" ? grp["active"] << goal : grp["completed"] << goal }
      save_goals(grp)
      grp
    else
      raise "Failed to fetch patient's goals."
    end
  end

  def description_options
    {
      "food-insecurity" => [
        ["Food security (finding)", "1078229009"],
      ],
      "homelessness" => [
        ["Housing security (finding)", "611211000124100"],
        ["Stably housed (finding)", "611221000124108"],
      ],
      "housing-instability" => [
        ["Housing security (finding)", "611211000124100"],
        ["Stably housed (finding)", "611221000124108"],
      ],
      "transportation-insecurity" => [
        ["Transportation security (finding)", "611271000124109"],
        ["Able to afford transportation-related expense (finding)", "611461000124101"],
        ["Has transportation that meets individual's cognitive needs (finding)", "611491000124109"],
        ["Has transportation to access community resources (finding)", "611511000124103"],
        ["Has transportation to access health care (finding)", "611521000124106"]
      ],
    }
  end
end
