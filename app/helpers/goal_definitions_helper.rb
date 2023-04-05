# Purpose: Contails valuesets, code systems, and other constants used in Goal resource
module GoalDefinitionsHelper
  ACHIEVEMENT_STATUSES = [
    { code: "INPROGRESS", display: "In progress" },
    { code: "IMPROVING", display: "Improving" },
    { code: "WORSENING", display: "Worsening" },
    { code: "NOCHANGE", display: "No Change" },
    { code: "ACHIEVED", display: "Achieved" },
    { code: "SUSTAINING", display: "Sustaining" },
    { code: "NOTACHIEVED", display: "Not Achieved" },
    { code: "NOPROGRESS", display: "No Progress" },
    { code: "NOTATTAINABLE", display: "Not Attainable" }
  ]
end
