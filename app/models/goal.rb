class Goal
  attr_reader :id, :description, :category, :status, :achievement_status, :start_date, :targets, :problems, :fhir_resource

  def initialize(fhir_goal, fhir_client: nil)
    @id = fhir_goal.id
    @fhir_resource = fhir_goal
    @fhir_resource.client = nil
    @description = read_codeable_concept(fhir_goal.description)
    @category = read_category(fhir_goal.category)
    @status = fhir_goal.lifecycleStatus
    @achievement_status = read_codeable_concept(fhir_goal.achievementStatus)
    @targets = get_targets(fhir_goal.target)
    @problems = get_problems(fhir_goal.addresses, fhir_client)
    @start_date = fhir_goal.statusDate
  end

  private

  def read_codeable_concept(codeable_concept)
    c = codeable_concept&.coding&.first
    c&.display ? c&.display : c&.code&.gsub("-", " ")&.titleize
  end

  def read_category(category)
    category&.map { |c| read_codeable_concept(c) }&.join(", ")
  end

  def get_problems(problems, fhir_client)
    probs = []
    problems&.each do |problem|
      prob_id = problem&.reference_id
      fhir_prob = fhir_client.read(FHIR::Condition, prob_id)&.resource
      # sometimes for some reason read returns FHIR::Bundle
      fhir_prob = fhir_prob&.entry&.first&.resource if fhir_prob.is_a?(FHIR::Bundle)
      probs << Condition.new(fhir_prob, fhir_client: fhir_client) if fhir_prob
    end
    probs
  end

  def get_targets(targets)
    targs = []
    targets&.each do |target|
      measure = read_codeable_concept(target&.measure)
      detail = read_codeable_concept(target&.detailCodeableConcept)
      due_date = target&.dueDate
      targs << Target.new(measure, detail, due_date)
    end
    targs
  end

  class Target
    attr_reader :measure, :detail, :due_date
    def initialize(measure, detail, due_date)
      @measure = measure
      @detail = detail
      @due_date = due_date
    end
  end
end
