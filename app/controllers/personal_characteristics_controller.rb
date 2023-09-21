class PersonalCharacteristicsController < ApplicationController
  before_action :require_client

  def new
  end

  def create
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

      get_client.create(obs)

      flash[:success] = "Personal characteristic created"
    rescue StandardError => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to create personal characteristic. #{e.message}"
    end
    Rails.cache.delete(personal_characteristics_key)
    set_active_tab("personal-characteristics")
    redirect_to dashboard_path
  end

  def destroy
    begin
      get_client.destroy(FHIR::Observation, params[:id])
      Rails.cache.delete(personal_characteristics_key)
      flash[:success] = "Personal characteristic deleted"
    rescue StandardError => e
      Rails.logger.error(e.full_message)

      flash[:error] = "Unable to delete personal characteristics. #{e.message}"
    end
    set_active_tab("personal-characteristics")
    redirect_to dashboard_path
  end

  private

  def set_fields_base_on_type(obs)
    case params[:type]
    when "personal_pronouns"
      add_personal_pronoun_attr(obs)
    when "ethnicity"
      add_ethnicity_attr(obs)
    when "race"
      # TODO
    when "sex_gender"
      # TODO
    when "sexual_orientation"
      # TODO
    when "gender_identity"
      # TODO
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
          "display": PERSONAL_PRONOUNS.find { |pronoun| pronoun[:code] == params[:value] }&.dig(:display)
        }
      ]
    }
  end

  #### Ethnicity type ####
  def add_ethnicity_attr(obs)
    obs.code = ethnicity_code
    obs.component = ethnicity_component
  end

  def ethnicity_code
    {
      "coding": [
        {
          "system": "http://loinc.org",
          "code": "69490-1",
          "display": "Ethnicity OMB.1997"
        }
      ]
    }
  end

  def ethnicity_component
    [
      {
        "code": ethnicity_code,
        "valueCodeableConcept": {
          "coding": [
            {
              "system": "urn:oid:2.16.840.1.113883.6.238",
              "code": params[:value],
              "display": ETHNICITY.find { |e| e[:code] == params[:value] }&.dig(:display)
            }
          ]
        }
      },
      if params[:ethnicity_description]
        {
          "code": ethnicity_code,
          "valueString": params[:ethnicity_description]
        }
      end
    ]
  end

  #### ALL Types ####
  def obs_meta
    {
      "profile": [
        PERSONAL_CHARACTERISTICS_PROFILES[params[:type]&.to_sym]
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
          "display": REPORTED_METHODS.dig(params[:reported_method]&.to_sym, :display)
        }
      ]
    }
  end

  def obs_subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient&.name
    }
  end
end
