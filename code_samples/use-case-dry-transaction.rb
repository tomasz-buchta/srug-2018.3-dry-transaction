#!ruby
require 'dry/transaction'
require 'pry'

class UpdateUser
  include Dry::Transaction

  step :validate
  step :save
  step :send_user_update_email

  private

  def validate(input)
    return Failure(:params_invalid) unless input[:email]
    Success(input)
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
create_user.call(email: 'john@doe.com') do |m|
  m.success do |user|
    puts "Updated user email to #{user[:email]}"
  end

  m.failure :validate do |validation|
    # You want something like validation.messages
    puts 'Invalid params for user'
  end

  m.failure do |error|
    puts "Sorry but #{error} stopped us"
  end
end
