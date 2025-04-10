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
  include QuestionnaireHelper
  include TasksHelper
  include ServiceRequestsHelper

  def organizations
    Rails.cache.fetch(organizations_key, expires_in: 1.minute) do
      response = get_client.search(FHIR::Organization, search: { parameters: { _sort: "-_lastUpdated" }}).resource

      if response.is_a?(FHIR::Bundle)
        entries = response.entry&.map(&:resource)
        entries&.map { |entry| Organization.new(entry) }
      end
    end
  end

  def consents
    Rails.cache.fetch(consents_key, expires_in: 1.minute) do
      response = get_client.search(FHIR::Consent, search: { parameters: { patient: patient_id }}).resource

      if response.is_a?(FHIR::Bundle)
        entries = response.entry&.map(&:resource)
        entries&.map { |entry| Consent.new(entry) }
      else
        Rails.logger.error "Error fetching consents"
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
