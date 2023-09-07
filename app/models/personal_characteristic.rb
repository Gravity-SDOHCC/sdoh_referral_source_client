# Personal characteristic model
class PersonalCharacteristic
  attr_reader :id, :subject_name, :subject_reference, :performer_name, :performer_reference, :fhir_resource,
              :reported_method, :type, :value

  def initialize(fhir_observation)
    @id = fhir_observation.id
    @fhir_resource = fhir_observation
    @fhir_resource.client = nil
    @subject_name = fhir_observation.subject&.display
    @subject_reference = fhir_observation.subject&.reference
    @performer_name = fhir_observation.performer&.map(&:display)&.join(', ')
    @performer_reference = fhir_observation.performer&.map(&:reference)&.join(', ')
    @reported_method = read_method(fhir_observation.local_method)
    @type = read_type(fhir_observation.code)
    @value = fhir_observation.component.present? ? read_component(fhir_observation.component) : read_value(fhir_observation.valueCodeableConcept)
  end

  private

  def read_method(fhir_observation_method)
    return if fhir_observation_method.nil?

    method = []
    fhir_observation_method.coding&.each do |method_obj|
      method << method_obj&.display
    end

    method.reject(&:blank?).join(', ')
  end

  def read_type(fhir_observation_code)
    return if fhir_observation_code.nil?

    coding = fhir_observation_code.coding&.first
    code = coding&.code
    display = coding&.display

    if code && display
      "#{display} (#{code})"
    elsif display
      display
    else
      code
    end
  end

  def read_value(fhir_observation_value)
    return if fhir_observation_value.nil?

    result = []
    fhir_observation_value.coding&.each do |code_item|
      code = code_item&.code
      display = code_item&.display

      if display && code
        result << "#{display} (#{code})"
      elsif code
        result << code
      end
    end

    result.join(', ')
  end

  def read_component(fhir_observation_component)
    component = []
    fhir_observation_component&.each do |component_obj|
      if component_obj&.valueCodeableConcept
        component << read_value(component_obj.valueCodeableConcept)
      end
    end
    component.join(', ')
  end
end
