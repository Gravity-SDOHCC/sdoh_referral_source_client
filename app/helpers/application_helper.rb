module ApplicationHelper
  include SessionHelper
  include PatientHelper
  include PractitionerHelper
  include PersonalCharacteristicsHelper
  include PersonalCharacteristicsDefinitionsHelper

  TEST_PATIENT_ID = "smart-1288992"
  TEST_PRACTITIONER_ID = "SDOHCC-PractitionerDrJanWaterExample"
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
