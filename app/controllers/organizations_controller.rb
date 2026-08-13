class OrganizationsController < ApplicationController
  before_action :require_client

  CAPACITY_EXTENSION_URL = "http://hl7.org/fhir/us/sdoh-clinicalcare/StructureDefinition/SDOHCC-ExtensionHealthcareServiceCapacityStatus".freeze

  # The four concepts bound to SDOHCC-ValueSetCapacityStatus, mapped to the
  # statuses the front end understands. These are the only capacity codes in
  # SDOHCC-CodeSystemTemporaryCodes: "at-capacity" and "no-capacity-has-waitlist"
  # were never real codes and are deliberately absent, so off-spec data surfaces
  # as "unknown" instead of being silently accepted.
  CAPACITY_CODE_MAP = {
    "capacity" => "available",
    "no-capacity" => "at-capacity",
    "waitlist" => "has-waitlist",
    "additional-assessment-required" => "assessment-required",
  }.freeze

  def check_capacity
    client = get_client
    org_id = params[:id]
    Rails.logger.info("[CHECK_CAPACITY] Org ID: #{org_id}")

    search_parameters = { organization: org_id }
    search_parameters["service-category"] = params[:category] if params[:category].present?

    bundle = client.search(FHIR::HealthcareService, search: { parameters: search_parameters }).resource
    services = bundle&.entry&.map(&:resource)&.compact || []
    Rails.logger.info("[CHECK_CAPACITY] Found #{services.size} HealthcareService(s): #{services.map(&:id)}")

    # Prefer the first service that actually carries a capacity extension
    extension = services.filter_map { |s| s.extension&.find { |e| e.url == CAPACITY_EXTENSION_URL } }.first
    # SDOHCC-ExtensionHealthcareServiceCapacityStatus is a complex extension:
    # capacityStatus is 1..1 and Extension.value[x] is prohibited (0..0).
    capacity_status_extension = extension&.extension&.find { |e| e.url == "capacityStatus" }
    code = capacity_status_extension&.valueCodeableConcept&.coding&.first&.code
    capacity = CAPACITY_CODE_MAP[code] || "unknown"
    Rails.logger.info("[CHECK_CAPACITY] Raw code: #{code.inspect}, normalized capacity: #{capacity}")

    render json: { capacity: capacity }
  rescue => e
    Rails.logger.error("[CHECK_CAPACITY] ERROR: #{e.full_message}")
    render json: { capacity: "unknown", error: e.message }, status: 502
  end

  def create
    org = FHIR::Organization.new(
      active: true,
      name: params[:name],
      contact: org_contact,
      address: org_address,
    )
    get_client.create(org)

    flash[:success] = "successfully created organization #{org.name}"
    Rails.cache.delete(organizations_key)
  rescue => e
    Rails.logger.error(e.full_message)

    flash[:error] = "Unable to create organization"
  ensure
    redirect_to dashboard_path
  end

  private

  def org_contact
    [
      {
        telecom: [
          {
            system: "phone",
            value: params[:phone],
          },
          {
            system: "email",
            value: params[:email],
          },
          {
            system: "url",
            value: params[:url],
          },
        ],
      },
    ]
  end

  def org_address
    [
      {
        line: [params[:street]],
        city: params[:city],
        state: params[:state],
        postalCode: params[:postal_code],
      },
    ]
  end
end
