#!ruby
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'dry-transaction'
  gem 'dry-validation'
  gem 'pry'
end

require 'dry/transaction'
require 'dry-validation'

Dry::Validation.load_extensions(:monads)

class TransferProject
  include Dry::Transaction

  step  :fetch_project # Returns Success(output) or Failure(:project_not_found)
  step  :fetch_user
  check :owner_can_release_ownership? # Returns true/false
  check :user_can_own_project? # Returns true/false
  step :transfer_project_ownership # Returns Success(input) or Failure(:project_transfer_error)
  step :notify_user # Returns Success(input) or Failure(:cannot_notify_user)
end

transfer_project = TransferProject.new
transfer_project.call(project_id: 123, to_email: 'test@email.com') do |m|
  m.success do |output|
    puts "transfered the project"
  end

  m.failure do |error|
    puts "Sorry but #{error} stopped us"
  end
end
