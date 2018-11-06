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

class UpdateUser
  include Dry::Transaction

  step :validate
  step :save
  step :send_user_update_email

  private

  def validate(input)
    schema = Dry::Validation.Schema do
      required(:email).filled(:str?)
    end
    schema.call(input).to_monad
  end

  def save(input)
    puts 'Saving'
    Success(input)
  end

  def send_user_update_email(input)
    puts "Sending notifaction email to #{input[:email]}"
    Success(input)
  end
end

create_user = UpdateUser.new
create_user.call(email: 'test@email.com') do |m|
  m.success do |user|
    puts "Updated user email to #{user[:email]}"
  end

  m.failure :validate do |validation|
    puts validation
    puts 'Invalid params for user'
  end

  m.failure do |error|
    puts "Sorry but #{error} stopped us"
  end
end
