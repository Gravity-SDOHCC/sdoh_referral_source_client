class HealthConcernsController < ApplicationController
  before_action :require_client

  def create

  end

  def update_health_concern
    begin
      concern = FHIR::Condition.read(params[:id])
      if concern
        concern.clinicalStatus = set_clinical_status if params[:status] != "problem"
        concern.abatementPeriod = set_period if params[:status] == "resolved"
        concern.onsetPeriod = set_period if params[:status] == "problem"
        set_category_to_problem(concern) if params[:status] == "problem"
        concern.update
        flash[:success] = "Health concern has been marked as #{params[:status]}"
      else
        flash[:error] = "Unable to update health concern: condition not found"
      end
    rescue => e
      flash[:error] = "Unable to update health concern: #{e.message}"
    end
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
end
