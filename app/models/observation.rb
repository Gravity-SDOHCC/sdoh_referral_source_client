class Observation
  attr_reader :id, :code, :category, :value, :effective_date_time, :fhir_resource

  def initialize(fhir_observation)
    @id = fhir_observation.id
    @fhir_resource = fhir_observation
    @code = get_code_string(fhir_observation.code)
    @category = get_category_display(fhir_observation.category)
    @value = get_code_string(fhir_observation.valueCodeableConcept)
    @effective_date_time = fhir_observation.effectiveDateTime
  end

  private

  def get_code_string(code)
    c = code&.coding&.first
    string = c.display ? "#{c.display} (#{c.code})" : c.code
  end

  def get_category_display(category)
    category&.map(&:coding)&.flatten&.map do |c|
      c.display || c.code&.gsub("-", " ")&.titleize
    end&.join("/ ")
  end
end
