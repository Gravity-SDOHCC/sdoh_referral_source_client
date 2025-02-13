class DocumentReference
  include ModelHelper

  attr_reader :id, :fhir_resource

  def initialize(fhir_qr, fhir_client: nil)
    @id = fhir_qr.id
    @fhir_resource = fhir_qr
    remove_client_instances(@fhir_resource)
  end
end
