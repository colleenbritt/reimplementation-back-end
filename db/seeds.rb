# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create questions for testing
Questionnaire.destroy_all # Clear the table
Question.destroy_all # Clear the table
Questionnaire.create!(id: 1, name: 'Testing', instructor_id: 1, private: 'false', min_question_score: 0, max_question_score: 10, default_num_choices: 4, type_id: 1)
Question.create!(id: 1, type: 'Checkbox', seq: 2.0, txt: 'test text for checkbox 1', weight: 11, questionnaire_id: 1, size: 10, alternatives: '')
Question.create!(id: 2, type: 'Checkbox', seq: 3.0, txt: 'test text for checkbox 2', weight: 12, questionnaire_id: 1, size: 10, alternatives: '')
Question.create!(id: 3, type: 'Checkbox', seq: 4.0, txt: 'test text for checkbox 3', weight: 13, questionnaire_id: 1, size: 10, alternatives: '')

# Create a role for testing
Role.destroy_all # Clear the table
Role.create!(id: 123, name: 'Test User')
# Role.create!(name: 'Unregistered user')
# Role.create!(name: 'Student')
# Role.create!(name: 'Teaching Assistant')
# Role.create!(name: 'Instructor')
# Role.create!(name: 'Administrator')
# Role.create!(name: 'Super Administrator')

AssignmentQuestionnaire.destroy_all
AssignmentQuestionnaire.create!(id: 1, assignment_id: 1, questionnaire_id: 1, user_id: 123, notification_limit: 15, questionnaire_weight: 100, dropdown: 1)
