module SessionHelper
  def save_client(client)
    @fhir_client = Rails.cache.fetch("client", expires_in: 1.day) do
      client
    end
  end

  def get_client
    @fhir_client = Rails.cache.read("client")
    FHIR::Model.client = @fhir_client
  end

  def client_connected?
    !!Rails.cache.read("client")
  end

  def save_server_base_url(base_url)
    session[:fhir_server_base_url] = base_url
  end

  def get_server_base_url
    session[:fhir_server_base_url]
  end

  def save_patients(patient_list)
    Rails.cache.write("patients", patient_list, expires_in: 1.day)
  end

  def get_patients
    Rails.cache.read("patients")
  end

  def save_patient_id(patient_id)
    session[:patient_id] = patient_id
  end

  def patient_id
    session[:patient_id]
  end

  def set_active_tab(tab)
    session[:active_tab] = tab
  end

  def active_tab
    session[:active_tab] || "personal-characteristics"
  end
end
