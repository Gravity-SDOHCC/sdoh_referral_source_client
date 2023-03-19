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

  # This method fetches the FHIR capability statement using the FHIR client object
  # def fetch_capability_statement
  #   @client.capability_statement
  # end

end

