class Question < ApplicationRecord
  belongs_to :questionnaire # each question belongs to a specific questionnaire
  #belongs_to :review_of_review_score # ditto
  has_many :question_advices, dependent: :destroy # for each question, there is separate advice about each possible score
  #has_many :signup_choices # ?? this may reference signup type questionnaires
  has_many :answers, dependent: :destroy

  validates :seq, presence: true # user must define sequence for a question
  validates :seq, numericality: true # sequence must be numeric
  validates :txt, length: { minimum: 0, allow_nil: false, message: "can't be nil" } # user must define text content for a question
  validates :type, presence: true # user must define type for a question
  validates :break_before, presence: true

  # has_paper_trail

  # Class variables
  NUMERIC = 'Numeric'.freeze # Display string for NUMERIC questions
  TRUE_FALSE = 'True/False'.freeze # Display string for TRUE_FALSE questions
  GRADING_TYPES = [[NUMERIC, false], [TRUE_FALSE, true]].freeze

  CHECKBOX = 'Checkbox'.freeze # Display string for NUMERIC questions
  TEXT_FIELD = 'TextField'.freeze
  TEXTAREA = 'TextArea'.freeze # Display string for TRUE_FALSE questions
  DROPDOWN = 'DropDown'.freeze
  UPLOAD_FILE = 'UploadFile'.freeze
  RATING = 'Rating'.freeze

  GRADING_TYPES_CUSTOM = [[CHECKBOX, 0], [TEXT_FIELD, 1], [TEXTAREA, 2], [DROPDOWN, 3], [UPLOAD_FILE, 4], [RATING, 5]].freeze
  WEIGHTS = [['1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]].freeze
  ANSWERS = [['1', 1], ['2', 2], ['3', 3], ['4', 4]].freeze # a hash used while creating a quiz questionnaire
  ANSWERS_TRUE_FALSE = [['1', 1], ['2', 2]].freeze
  ANSWERS_MCQ_CHECKED = [['1', 1], ['0', 2]].freeze
  RATINGS = [['Very Easy', 1], ['Easy', 2], ['Medium', 3], ['Difficult', 4], ['Very Difficult', 5]].freeze
  attr_accessor :checked

  # Delete the question.
  def delete
    QuestionAdvice.where(question_id: id).find_each(&:destroy)
    destroy
  end

  # For quiz questions, we store 'TrueFalse', 'MultipleChoiceCheckbox', 'MultipleChoiceRadio' in the DB, and the full names are returned below
  def formatted_question_type
    type = self.type
    statement = ''
    case type
    when 'TrueFalse'
      statement = 'True/False'
    when 'MultipleChoiceCheckbox'
      statement = 'Multiple Choice - Checked'
    when 'MultipleChoiceRadio'
      statement = 'Multiple Choice - Radio'
    end
    statement
  end

  # Placeholder methods, override in derived classes if required.
  # This method decides what to display if an instructor (etc.) is creating or editing a questionnaire.
  def edit
    nil
  end

  # This method decide what to display if an instructor (etc.) is viewing a questionnaire.
  def view_question_text
    nil
  end

  # This method decide what to display if a student is filling out a questionnaire.
  def view_completed_question
    nil
  end

  # This method decide what to display if a student is viewing a filled-out questionnaire.
  def complete
    nil
  end

  # This method computes the question score.
  def self.compute_question_score
    0
  end

  # This method returns questions (question_ids) in one assignment whose comments field are meaningful (ScoredQuestion and TextArea)
  def self.questions_with_comments(assignment_id)
    question_ids = []
    questionnaires = Assignment.find(assignment_id).questionnaires.select { |questionnaire| questionnaire.type == 'ReviewQuestionnaire' }
    questionnaires.each do |questionnaire|
      questions = questionnaire.questions.select { |question| question.is_a?(ScoredQuestion) || question.instance_of?(TextArea) }
      questions.each { |question| question_ids << question.id }
    end
    question_ids
  end

  # Imports an existing questionnaire given by the user.
  def self.import(row, _row_header, _session, q_id = nil)
    if row.length != 5
      raise ArgumentError,  'Not enough items: expect 3 columns: your login name, your full name' \
                            '(first and last name, not separated with the delimiter), and your email.'
    end
    questionnaire = Questionnaire.find_by(id: q_id)
    raise ArgumentError, 'Questionnaire Not Found' if questionnaire.nil?

    questions = questionnaire.questions
    qid = 0
    questions.each do |q|
      if q.seq == row[2].strip.to_f
        qid = q.id
        break
      end
    end

    if qid.positive?
      question = Question.find_by(id: qid)
      attributes = {}
      attributes['txt'] = row[0].strip
      attributes['type'] = row[1].strip
      attributes['seq'] = row[2].strip.to_f
      attributes['size'] = row[3].strip
      attributes['break_before'] = row[4].strip
      question.questionnaire_id = q_id
      question.update(attributes)
    else
      attributes = {}
      attributes['txt'] = row[0].strip
      attributes['type'] = row[1].strip
      attributes['seq'] = row[2].strip.to_f
      attributes['size'] = row[3].strip
      question = Question.new(attributes)
      question.questionnaire_id = q_id
      question.save
    end
  end

  # Exports an array of the question model fields.
  def self.export_fields(_options)
    fields = ['Seq', 'Question', 'Type', 'Weight', 'text area size', 'max_label', 'min_label']
    fields
  end

  # Exports questionnaire to a CSV file.
  def self.export(csv, parent_id, _options)
    questionnaire = Questionnaire.find(parent_id)
    questionnaire.questions.each do |question|
      csv << [question.seq, question.txt, question.type,
              question.weight, question.size, question.max_label,
              question.min_label]
    end
  end
end
