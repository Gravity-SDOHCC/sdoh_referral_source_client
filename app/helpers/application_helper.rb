module ApplicationHelper
  # TODO: move these to a separate module. make sure to include all modules in ApplicationHelper, which will be included in ApplicationController
  # TODO: Make sure to add doc comments to each method (params, return value, etc)
  #### session helpers, client, patient, practitioner ####

  def save_client(client)
    session[:client] = compress_object(client)
  end

  def get_client
    @fhir_client = decompress_object(session[:client])
  end

  def client_connected?
    !!session[:client]
  end

  def clean_session
    reset_session
    # ActiveRecord::SessionStore::Session.delete_all
  end

  def get_current_patient
    @current_patient = decompress_object(session[:patient])
  end

  def save_patient(patient)
    session[:patient] = compress_object(patient)
  end

  def save_patient_id(patient_id)
    session[:patient_id] = patient_id
  end

  def patient_id
    session[:patient_id]
  end

  def save_current_practitioner(practitioner)
    session[:practitioner] = compress_object(practitioner)
  end

  def save_practitioner_id(practitioner_id)
    session[:practitioner_id] = practitioner_id
  end

  def get_current_practitioner
    @current_practitioner = decompress_object(session[:practitioner])
  end

  def practitioner_id
    session[:practitioner_id]
  end

  #### Flash helpers ####

  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "success"
    when :error
      "danger"
    when :alert
      "warning"
    when :notice
      "info"
    else
      flash_type.to_s
    end
  end

  #### Compression/decompression helpers ####

  def compress_object(obj)
    compressed_obj = Base64.encode64(Zlib::Deflate.deflate(obj.to_json))
  end

  def decompress_object(obj)
    decompressed_obj = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(obj)))
  end
end
