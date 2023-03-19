class AddIndexToFhirServers < ActiveRecord::Migration[6.1]
  def change
    add_index :fhir_servers, :base_url, unique: true
  end
end
