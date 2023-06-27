# Purpose: Contails valuesets, code systems, and other constants used in Goal resource
module GoalDefinitionsHelper
  def achievement_status
    [
      { code: "in-progress", display: "In progress" },
      { code: "improving", display: "Improving" },
      { code: "worsening", display: "Worsening" },
      { code: "no-change", display: "No Change" },
      { code: "achieved", display: "Achieved" },
      { code: "sustaining", display: "Sustaining" },
      { code: "not-achieved", display: "Not Achieved" },
      { code: " no-progress", display: "No Progress" },
      { code: "not-attainable", display: "Not Attainable" },
    ]
  end

  def goal_category
    [
      {
        code: "food-insecurity",
        display: "Food Insecurity",
      },
      {
        code: "transportation-insecurity",
        display: "Transportation Insecurity",
      },
      {
        code: "homelessness",
        display: "Homelessness",
      },
      {
        code: "housing-instability",
        display: "Housing Instability",
      },
    ]
  end

  # system": "http://snomed.info/sct
  GOAL_DESCRIPTIONS = {
    "611271000124109" => "Transportation security (finding)",
    "611461000124101" => "Able to afford transportation-related expense (finding)",
    "611491000124109" => "Has transportation that meets individual's cognitive needs (finding)",
    "611511000124103" => "Has transportation to access community resources (finding)",
    "611521000124106" => "Has transportation to access health care (finding)",
    "1078229009" => "Food security (finding)",
    "611211000124100" => "Housing security (finding)",
    "611221000124108" => "Stably housed (finding)",
  }
end
