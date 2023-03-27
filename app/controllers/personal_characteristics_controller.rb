class PersonalCharacteristicsController < ApplicationController
  before_action :require_client

  def create

  end

  def destroy
    pcs = get_personal_characteristics
    byebug
    pc = pcs&.find { |pc| pc.id == params[:id] }
    if pc.nil?
      flash[:error] = "Personal characteristic not found"
    else
      begin
        pc.fhir_resource.destroy
        pcs.delete(pc)
        byebug
        save_personal_characteristics(pcs)
        flash[:success] = "Personal characteristic deleted"
      rescue StandardError => e
        flash[:error] = "Unable to delete personal characteristics. #{e.message}"
      end
    end
    redirect_to dashboard_path
  end
end
