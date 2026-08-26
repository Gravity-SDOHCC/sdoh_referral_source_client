class ApplicationController < ActionController::Base

  # fhir_client walks a resource with FHIR::Model#each_element before it hands
  # back the server's reply, and a raw Hash cannot be walked. Any resource that
  # still carried one turned every server rejection into
  # "undefined method `each_element' for Hash" instead of the OperationOutcome
  # the server actually sent. The builders in these controllers describe
  # resources as hashes, so each one becomes the FHIR type it belongs to on the
  # way onto the resource. FHIR::Model.new already coerces the nested hashes.
  def as_fhir(fhir_class, attributes)
    return if attributes.blank?
    return attributes.map { |attribute| fhir_class.new(attribute) } if attributes.is_a?(Array)

    fhir_class.new(attributes)
  end
  protect_from_forgery with: :null_session
  include ApplicationHelper

  def require_client
    if client_connected?
      get_client
    else
      Rails.logger.info("Session expired redirecting to root from #{request&.fullpath}")

      reset_session
      clear_cache

      flash[:error] = "Your session has expired. Please connect to a FHIR server"
      redirect_to home_path
    end
  end
end
