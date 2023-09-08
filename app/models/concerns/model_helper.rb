# app/models/concerns/model_helper.rb
module ModelHelper
  extend ActiveSupport::Concern

  def remove_client_instances(resource)
    resource.client = nil
    @fhir_resource.each_element { |element| element.client = nil if element.respond_to? :client }
  end

  def format_phone(fhir_telecom_arr)
    phone_numbers = fhir_telecom_arr&.select do |telecom|
      telecom&.system == "phone"
    end.map { |phone| phone.value }

    phone_numbers&.join(", ")
  end

  def format_email(fhir_telecom_arr)
    email_addresses = fhir_telecom_arr&.select do |telecom|
      telecom&.system == "email"
    end.map { |email| email.value }

    email_addresses&.join(", ")
  end

  def format_url(fhir_telecom_arr)
    urls = fhir_telecom_arr&.select do |telecom|
      telecom&.system == "url"
    end.map { |url| url.value }

    urls&.join(", ")
  end

  def format_name(fhir_name_array)
    latest_name = latest_start_date_object(fhir_name_array)
    return "No name provided" if latest_name.nil?

    given_names = latest_name.given.join(" ") if latest_name.given
    family_name = latest_name.family
    suffix = latest_name.suffix.join(" ") if latest_name.suffix

    [family_name, given_names, suffix].compact.join(" ")
  end

  def format_address(fhir_address_arr)
    latest_address = latest_start_date_object(fhir_address_arr)
    return "No address provided" if latest_address.nil?

    line = latest_address.line.join(", ") if latest_address.line
    city = latest_address.city
    state = latest_address.state
    postal_code = latest_address.postalCode
    country = latest_address.country

    [line, city, state, postal_code, country].compact.join(", ")
  end

  def latest_start_date_object(array)
    return if array.nil?
    latest_object = nil
    latest_start_date = nil

    array.each do |item|
      if item.period&.start
        start_date = Date.parse(item.period.start)

        if latest_start_date.nil? || start_date > latest_start_date
          latest_start_date = start_date
          latest_object = item
        end
      end
    end

    latest_object.nil? ? array.first : latest_object
  end
end
