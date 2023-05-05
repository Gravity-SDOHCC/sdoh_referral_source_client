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
    ]
  end

  # system": "http://snomed.info/sct
  GOAL_DESCRIPTION = {
    "food-insecurity" => {
      code: "1078229009",
      display: "Food security",
    },
    "transportation-insecurity" => {
      code: "106854209",
      display: "Transportation security",
    },
    "homelessness" => {
      code: "425067005",
      display: "Homelessness",
    },
  }
end
