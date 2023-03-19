class CreateFhirServers < ActiveRecord::Migration[6.1]
  def change
    create_table :fhir_servers do |t|
      t.string :name
      t.string :base_url

      t.timestamps
    end
  end
end
