class ConditionsController < ApplicationController
  before_action :require_client

  def create
    begin
      condition = FHIR::Condition.new
      condition.meta = meta
      condition.clinicalStatus = clinical_status
      condition.verificationStatus = verification_status
      condition.category = category
      condition.code = code
      condition.subject = subject
      condition.onsetPeriod = onset_period
      condition.asserter = asserter

      get_client.create(condition)

      flash[:success] = "Condition has been created"
    rescue => e
      flash[:error] = "Unable to create condition. #{e.message}"
    end
    tab = params[:type] == "health-concern" ? "health-concerns" : "problems"
    set_active_tab(tab)
    Rails.cache.delete(conditions_key)
    redirect_to dashboard_path(active_tab: "health-concerns")
  end

  def update_condition
    begin
      concern = get_client.read(FHIR::Condition, params[:id])
      if concern
        concern.clinicalStatus = set_clinical_status if params[:status] != "problem"
        concern.abatementPeriod = set_period if params[:status] == "resolved"
        concern.onsetPeriod = set_period if params[:status] == "problem"
        set_category_to_problem(concern) if params[:status] == "problem"

        get_client.update(concern, concern.id)

        flash[:success] = "Health concern has been marked as #{params[:status]}"
      else
        flash[:error] = "Unable to update health concern: condition not found"
      end
    rescue => e
      flash[:error] = "Unable to update health concern: #{e.message}"
    end
    set_active_tab("health-concerns")
    Rails.cache.delete(conditions_key)
    redirect_to dashboard_path
  end

  private

  def set_clinical_status
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
          "code": params[:status],
          "display": params[:status].titleize
        }
      ]
    }
  end

  def set_period
    {
      "start": Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.%3NZ')
    }
  end

  def set_category_to_problem(concern)
    concern.category.each do |category|
      if category.coding.first.system ==  "http://hl7.org/fhir/us/core/CodeSystem/condition-category"
        category.coding.first.code = "problem-list-item"
        category.coding.first.display = "Problem List Item"
      end
    end
    puts "Promoted to problem? #{concern.category.first.coding.first.code == "problem-list-item"}"
  end

  ### Create a new health concern ###
  def meta
    {
      "profile": [CONDITION_PROFILE]
    }
  end

  def clinical_status
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
          "code": "active",
          "display": "Active"
        }
      ]
    }
  end

  def verification_status
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
          "code": "confirmed",
          "display": "Confirmed"
        }
      ]
    }
  end

  def category
    [
      {
        "coding": [
          {
            "system": CONDITION_CATEGORY_US_CORE_CODE_SYSTEM ,
            "code": params[:type],
            "display": params[:type].titleize
          }
        ]
      },
      {
        "coding": [
          {
            "system": CATEGORY_SDOH_CODE_SYSTEM,
            "code": params[:category],
            "display": params[:category].titleize
          }
        ]
      }
    ]
  end

  def code
    {
      "coding": [
        {
          "system": SNOMED_CODE_SYSTEM,
          "code": params[:snomed_code],
          "display": params[:snomed_display]
        },
        {
          "system": ICD_10_CODE_SYSTEM,
          "code": params[:icd_code],
          "display": params[:icd_display]
        }
      ]
    }
  end

  def subject
    {
      "reference": "Patient/#{patient_id}",
      "display": current_patient.name
    }
  end

  def onset_period
    {
      "start": params[:effective_date].to_time.utc.strftime('%Y-%m-%dT%H:%M:%S.%3NZ')
    }
  end

  def asserter
    {
      "reference": "Practitioner/#{practitioner_id}",
      "display": get_current_practitioner&.name
    }
  end
end
