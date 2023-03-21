# Patient Model
class Patient
  attr_reader :id, :fhir_resource, :name, :dob, :medical_record_number, :gender, :address,
              :phone, :email, :race, :ethnicity, :marital_status, :birthsex
  def initialize(fhir_patient)
    @id = fhir_patient.id
    @fhir_resource = fhir_patient
    @name = format_name(fhir_patient.name)
    @dob = fhir_patient.birthDate
    @medical_record_number = get_med_rec_num(fhir_patient.identifier)
    @gender = fhir_patient.gender
    @address = format_address(fhir_patient.address)
    @phone = format_phone(fhir_patient.telecom)
    @email = format_email(fhir_patient.telecom)
    characteristics = read_characteristics(fhir_patient.extension)
    @race = characteristics[:race]
    @ethnicity = characteristics[:ethnicity]
    @birthsex = characteristics[:birthsex]
    @marital_status = fhir_patient.maritalStatus.coding[0]&.display if fhir_patient.maritalStatus
  end

  private

  def get_med_rec_num(fhir_patient_id_arr)
    fhir_patient_id_arr.each do |id_obj|
      if id_obj.type && id_obj.type.coding
        id_obj.type.coding.each do |coding|
          if coding.code == 'MR'
            return id_obj.value
          end
        end
      end
    end
    nil
  end

  def read_characteristics(fhir_patient_extension_arr)
    characteristics = { race: [], ethnicity: [], birthsex: nil }

    fhir_patient_extension_arr.each do |ext|
      case ext.url
      when 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
        ext.extension.each do |race_ext|
          if race_ext.url == 'ombCategory' && race_ext.valueCoding && race_ext.valueCoding.display
            characteristics[:race] << race_ext.valueCoding.display
          end
        end
      when 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity'
        ext.extension.each do |ethnicity_ext|
          if ethnicity_ext.url == 'ombCategory' && ethnicity_ext.valueCoding && ethnicity_ext.valueCoding.display
            characteristics[:ethnicity] << ethnicity_ext.valueCoding.display
          end
        end
      when 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex'
        characteristics[:birthsex] = ext.valueCode
      end
    end

    characteristics[:race] = characteristics[:race].join(', ')
    characteristics[:ethnicity] = characteristics[:ethnicity].join(', ')

    characteristics
  end

  def format_phone(fhir_patient_telecom_arr)
    phone_numbers = fhir_patient_telecom_arr.select do |telecom|
      telecom.system == 'phone'
    end.map { |phone| phone.value }

    phone_numbers.join(', ')
  end

  def format_email(fhir_patient_telecom_arr)
    email_addresses = fhir_patient_telecom_arr.select do |telecom|
      telecom.system == 'email'
    end.map { |email| email.value }

    email_addresses.join(', ')
  end


  def format_name(fhir_name_array)
    latest_name = latest_start_date_object(fhir_name_array)
    return "No name provided" if latest_name.nil?

    given_names = latest_name.given.join(' ') if latest_name.given
    family_name = latest_name.family
    suffix = latest_name.suffix.join(' ') if latest_name.suffix

    [family_name, given_names, suffix].compact.join(' ')
  end

  def format_address(fhir_patient_address_arr)
    latest_address = latest_start_date_object(fhir_patient_address_arr)
    return "No address provided" if latest_address.nil?

    line = latest_address.line.join(', ') if latest_address.line
    city = latest_address.city
    state = latest_address.state
    postal_code = latest_address.postalCode
    country = latest_address.country

    [line, city, state, postal_code, country].compact.join(', ')
  end

  def latest_start_date_object(array)
    return if array.nil?
    latest_object = nil
    latest_start_date = nil

    array.each do |item|
      if item.period && item.period.start
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
