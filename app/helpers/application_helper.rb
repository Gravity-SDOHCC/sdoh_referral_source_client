module ApplicationHelper
  include SessionHelper
  include PatientHelper
  include PractitionerHelper
  include PersonalCharacteristicsHelper
  include PersonalCharacteristicsDefinitionsHelper
  include ConditionsHelper
  include ConditionDefinitionsHelper
  include GoalsHelper
  include GoalDefinitionsHelper
  include TasksHelper
  include ServiceRequestsHelper

  TEST_PATIENT_ID = "smart-1288992"
  TEST_PRACTITIONER_ID = "SDOHCC-PractitionerDrJanWaterExample"

  def organizations
    Rails.cache.fetch("organizations", expires_in: 1.day) do
      response = FHIR::Organization.search(_sort: "-_lastUpdated")

      if response.is_a?(FHIR::Bundle)
        entries = response.entry.map(&:resource)
        entries.map { |entry| Organization.new(entry) }
      end
    end
  end

  #### Flash helpers ####
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "success"
    when :error
      "danger"
    when :alert
      "warning"
    when :notice
      "info"
    else
      flash_type.to_s
    end
  end
end
