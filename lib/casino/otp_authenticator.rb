require 'active_record'

class CASino::OtpAuthenticator

  class AuthDatabase < ::ActiveRecord::Base
    self.abstract_class = true
  end

  # @param [Hash] options
  def initialize(options)

  end

  def validate(username, password)

  rescue ActiveRecord::RecordNotFound
    false
  end

  def load_user_data(username)

  rescue ActiveRecord::RecordNotFound
    nil
  end
end
