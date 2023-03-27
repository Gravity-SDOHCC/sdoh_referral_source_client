module SessionHelper
  include UtilsHelper

  def save_client(client)
    # DO NOT compress client object because you will get an error when trying to decompress it (kuz of http client)
    session[:client] = client
  end

  def get_client
    @fhir_client = session[:client]
    FHIR::Model.client = @fhir_client
  end

  def client_connected?
    !!session[:client]
  end

  def clean_session
    reset_session
  end

  def save_server_base_url(base_url)
    session[:fhir_server_base_url] = base_url
  end

  def get_server_base_url
    session[:fhir_server_base_url]
  end

  def save_patients(patient_list)
    session[:patients] = compress_object(patient_list)
  end

  def get_patients
    decompress_object(session[:patients])
  end

  def save_patient_id(patient_id)
    session[:patient_id] = patient_id
  end

  def patient_id
    session[:patient_id]
  end

end
