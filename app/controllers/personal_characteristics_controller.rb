class PersonalCharacteristicsController < ApplicationController

  before_action :require_client

  def new

  end

  def create
    # Rails.cache.clear
    pcs = get_personal_characteristics
    # byebug
    begin
      obs = FHIR::Observation.new
      obs.meta = obs_meta
      obs.status = "final"
      obs.category = obs_category
      obs.local_method = obs_method
      obs.subject = obs_subject
      obs.effectiveDateTime = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.%3NZ')
      obs.performer = [obs_subject] if params[:reported_method] == "self-reported"
      obs.derivedFrom = [FHIR::Reference.new(reference: params[:derived_from])] if params[:derived_from].present?
      set_fields_base_on_type(obs)
      result = @fhir_client.create(obs) #obs.create
      pcs << PersonalCharacteristic.new(result)
      # byebug
      save_personal_characteristics(pcs)

      flash[:success] = "Personal characteristic created"
      expires_now
    rescue StandardError => e
      flash[:error] = "Unable to create personal characteristic. #{e.message}"
    end
    redirect_to dashboard_path
  end

  def destroy
    pcs = get_personal_characteristics
    pc = pcs&.find { |pc| pc.id == params[:id] }
    if pc.nil?
      flash[:error] = "Personal characteristic not found"
    else
      begin
        pc.fhir_resource.destroy
        pcs.delete(pc)
        save_personal_characteristics(pcs)
        flash[:success] = "Personal characteristic deleted"
      rescue StandardError => e
        flash[:error] = "Unable to delete personal characteristics. #{e.message}"
      end
    end
    redirect_to dashboard_path
  end

  private

  def set_fields_base_on_type(obs)
    case params[:type]
    when "personal_pronouns"
     add_personal_pronoun_attr(obs)
    end
  end

  #### Personal Pronoun type ####
  def add_personal_pronoun_attr(obs)
    obs.code = personal_pronoun_code
    obs.valueCodeableConcept = personal_pronoun_valueCodeableConcept
  end

  def personal_pronoun_code
    {
      "coding": [
        {
          "system": "http://loinc.org",
          "code": "90778-2",
          "display": "Personal pronoun"
        }
      ]
    }
  end

  def personal_pronoun_valueCodeableConcept
    {
      "coding": [
        {
          "system": "http://loinc.org",
          "code": params[:value],
          "display": PERSONAL_PRONOUNS.find { |pronoun| pronoun[:code] == params[:value] }[:display]
        }
      ]
    }
  end

  #### ALL Types ####
  def obs_meta
    {
      "profile": [
        PERSONAL_CHARACTERISTICS_PROFILES[params[:type].to_sym]
      ]
    }
  end

  def obs_category
    [
      {
        "coding": [
          {
            "system": "http://hl7.org/fhir/us/sdoh-clinicalcare/CodeSystem/SDOHCC-CodeSystemTemporaryCodes",
            "code": "personal-characteristic"
          }
        ]
      }
    ]
  end

  def obs_method
    {
      "coding": [
        {
          "system": REPORTED_METHODS_SYSTEM,
          "code": params[:reported_method],
          "display": REPORTED_METHODS[params[:reported_method].to_sym][:display]
        }
      ]
    }
  end

  def obs_subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient.name
    }
  end

end
