# Practitioner Model
class Practitioner
  include ModelHelper

  attr_reader :id, :name, :address, :active, :npi, :fhir_resource

  def initialize(fhir_practitioner)
    @id = fhir_practitioner.id
    @fhir_resource = fhir_practitioner
    remove_client_instances(@fhir_resource)
    @name = format_name(fhir_practitioner.name)
    @address = format_address(fhir_practitioner.address)
    @active = fhir_practitioner.active
    @npi = get_npi(fhir_practitioner.identifier)
  end

  private

  def get_npi(fhir_practitioner_id_arr)
    fhir_practitioner_id_arr&.each do |id_obj|
      if id_obj&.system&.include?('npi')
        return id_obj.value
      end
    end
  end
end
