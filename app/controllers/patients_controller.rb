class PatientsController < ApplicationController
  before_action :require_client, :set_patient_id

  def index
    redirect_to dashboard_path
  end

  def show
    redirect_to dashboard_path
  end

  private

  def set_patient_id
    puts "CHECK CHECK I AM IN PatientsController#set_patient_id. params[:patient_id]: #{params[:id]}."
    save_patient_id(params[:id])
  end
end
