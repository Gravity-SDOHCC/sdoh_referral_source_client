require 'securerandom'
require 'base64'

module SessionHelper
  def save_client(client)
    @fhir_client = Rails.cache.fetch(client_key, expires_in: 1.day) do
      client
    end
  end

  def get_client
    @fhir_client = Rails.cache.read(client_key)
  end

  def client_connected?
    !!Rails.cache.read(client_key)
  end

  def save_server_base_url(base_url)
    session[:fhir_server_base_url] = base_url
  end

  def get_server_base_url
    session[:fhir_server_base_url]
  end

  def save_patients(patient_list)
    Rails.cache.write(patients_key, patient_list, expires_in: 1.day)
  end

  def get_patients
    Rails.cache.read(patients_key)
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

  def session_id
    session.id
  end

  def clear_cache
    Rails.cache.delete(client_key)
    Rails.cache.delete(patients_key)
    Rails.cache.delete(organizations_key)
    Rails.cache.delete(consents_key)
    Rails.cache.delete(conditions_key)
    Rails.cache.delete(goals_key)
    Rails.cache.delete(service_requests_key)
    Rails.cache.delete(practitioner_key)
    Rails.cache.delete(practitioners_key)
    Rails.cache.delete(practitioner_role_id_key)
    Rails.cache.delete(tasks_key)
    Rails.cache.delete(personal_characteristics_key)
  end

  def client_key
    "#{session_id}_client"
  end

  def patients_key
    "#{session_id}_patients"
  end

  def organizations_key
    "#{session_id}_organizations"
  end

  def consents_key
    "#{session_id}_consents_#{patient_id}"
  end

  def conditions_key
    "#{session_id}_conditions_#{patient_id}"
  end

  def goals_key
    "#{session_id}_goals_#{patient_id}"
  end

  def service_requests_key
    "#{session_id}_service_requests"
  end

  def practitioner_key
    "#{session_id}_practitioner_#{get_server_base_url}"
  end

  def practitioners_key
    "#{session_id}_practitioners_#{get_server_base_url}"
  end

  def practitioner_role_id_key
    "#{session_id}_practitioner_role_id_#{get_server_base_url}"
  end

  def tasks_key
    "#{session_id}_tasks_#{patient_id}"
  end

  def personal_characteristics_key
    "#{session_id}_personal_characteristics"
  end
end
