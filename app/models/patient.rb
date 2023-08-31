# Patient Model
class Patient < Resource
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
    @marital_status = fhir_patient.maritalStatus.coding&.first&.display if fhir_patient.maritalStatus
  end

  private

  def get_med_rec_num(fhir_patient_id_arr)
    fhir_patient_id_arr.each do |id_obj|
      if id_obj&.type&.coding
        id_obj.type.coding.each do |coding|
          if coding&.code == 'MR'
            return id_obj.value
          end
        end
      end
    end
    nil
  end

  def read_characteristics(fhir_patient_extension_arr)
    characteristics = { race: [], ethnicity: [], birthsex: nil }

    fhir_patient_extension_arr&.each do |ext|
      case ext&.url
      when 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
        ext.extension&.each do |race_ext|
          if race_ext&.url == 'ombCategory' && race_ext&.valueCoding&.display
            characteristics[:race] << race_ext.valueCoding.display
          end
        end
      when 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity'
        ext.extension&.each do |ethnicity_ext|
          if ethnicity_ext&.url == 'ombCategory' && ethnicity_ext&.valueCoding&.display
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
end
