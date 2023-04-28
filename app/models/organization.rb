# Organization Model
class Organization < Resource
  attr_reader :id, :fhir_resource, :name, :address, :phone, :email, :url

  def initialize(fhir_organization)
    @id = fhir_organization.id
    @fhir_resource = fhir_organization
    @name = fhir_organization.name
    @address = format_address(fhir_organization.address)
    @phone = format_phone(fhir_organization.telecom)
    @email = format_email(fhir_organization.telecom)
    @url = format_url(fhir_organization.telecom)
  end
end
