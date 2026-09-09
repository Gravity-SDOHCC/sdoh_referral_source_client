module SocialRisksHelper
  include SessionHelper

  def fetch_social_risk_assessments
    client = get_client
    response = client.search(
      FHIR::QuestionnaireResponse,
      search: {
        parameters: {
          subject: "Patient/#{patient_id}",
          _sort: "-authored",
        },
      },
    )

    if response.response[:code] == 200 && response.resource.is_a?(FHIR::Bundle)
      entries = response.resource.entry&.map(&:resource) || []
      [true, entries.map { |entry| QuestionnaireResponse.new(entry) }]
    else
      Rails.logger.error("Failed to fetch social risk assessments. Status: #{response.response[:code]} - #{response.response[:body]}")
      [false, "Failed to fetch social risk assessments."]
    end
  rescue StandardError => e
    Rails.logger.error(e.full_message)
    [false, "Failed to fetch social risk assessments. #{e.message}"]
  end

  # The Observations that carry the patient's social risk: the derived
  # assessments and the individual screening answers behind them.
  #
  # SDOHCC-TaskForReferralManagement, "Content-Rich Referral": "The requester
  # may want to include in the request the completed assessment(s) that led to
  # the action of submitting a referral. The requester will reference those
  # assessments (QuestionnaireResponse, SDOHCC Observation Screening Response,
  # etc.) in Task.input." These are the Observations that sentence names.
  #
  # Searched by profile rather than by category: an SDOHCC-ObservationAssessment
  # carries category sdoh on some domains and social-history on others, so
  # category=sdoh silently drops a quarter of them. Grouped by profile too - a
  # derived finding and a single questionnaire answer are not the same kind of
  # thing to attach to a referral, and there are far more of the latter.
  def fetch_sdoh_observations
    client = get_client
    response = client.search(
      FHIR::Observation,
      search: {
        parameters: {
          subject: "Patient/#{patient_id}",
          _profile: [FhirProfiles::OBSERVATION_ASSESSMENT, FhirProfiles::OBSERVATION_SCREENING_RESPONSE].join(","),
          _sort: "-date",
        },
      },
    )

    if response.response[:code] == 200 && response.resource.is_a?(FHIR::Bundle)
      entries = response.resource.entry&.map(&:resource) || []
      grouped = entries.map { |entry| Observation.new(entry) }.group_by do |observation|
        profiles = Array(observation.fhir_resource&.meta&.profile)
        profiles.include?(FhirProfiles::OBSERVATION_ASSESSMENT) ? "assessment" : "screening-response"
      end
      [true, grouped]
    else
      Rails.logger.error("Failed to fetch SDOH observations. Status: #{response.response[:code]} - #{response.response[:body]}")
      [false, "Failed to fetch SDOH observations."]
    end
  rescue StandardError => e
    Rails.logger.error(e.full_message)
    [false, "Failed to fetch SDOH observations. #{e.message}"]
  end
end
