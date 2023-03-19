# FhirClient Model
class FhirClient < FHIR::Client

  # This method runs every time a new FhirClient object is created (with a specific base URL)
  def initialize(base_url)
   super(base_url)
  end

  def self.setup_client(base_url)
    client = self.new(base_url)
    client.use_r4
    client
  end

  def self.fetch_practitioner(client, practitioner_id)
    client.read(FHIR::Practitioner, practitioner_id)
  end

  def self.fetch_condition(client, patient_id)
    client.search(FHIR::Condition, search: { parameters: { patient: patient_id } })
  end

  def self.fetch_observation(client, patient_id)
    client.search(FHIR::Observation, search: { parameters: { patient: patient_id } })
  end

  def self.fetch_procedure(client, patient_id)
    client.search(FHIR::Procedure, search: { parameters: { patient: patient_id } })
  end

  def self.fetch_organization(client, organization_id)
    client.read(FHIR::Organization, organization_id)
  end

  def self.fetch_organization_by_name(client, organization_name)
    client.search(FHIR::Organization, search: { parameters: { name: organization_name } })
  end

end

