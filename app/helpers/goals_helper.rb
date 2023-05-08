module GoalsHelper
  include SessionHelper

  def save_goals(goals)
    Rails.cache.write("goals_#{patient_id}", goals, expires_in: 1.minute)
  end

  def fetch_goals
    response = FHIR::Goal.search(subject: patient_id, _sort: "-_lastUpdated")
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
end
