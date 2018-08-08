require 'active_record'

class CASino::OtpAuthenticator

  class AuthDatabase < ::ActiveRecord::Base
    self.abstract_class = true
  end

  def initialize(options)
    option_initialize(options)
    validate_option_data
    user_model_name = classify_table(@options[:user_table])
    otp_model_name = classify_table(@options[:otp_table])
    user_model_class_name = "#{self.class.to_s}::#{user_model_name}"
    otp_model_class_name = "#{self.class.to_s}::#{otp_model_name}"
    load_class(user_model_class_name, @options[:user_table])
    load_class(otp_model_class_name, @options[:otp_table])
    @user_model = user_model_class_name.constantize
    @otp_model = otp_model_class_name.constantize
    @user_model.establish_connection @options[:connection]
    @otp_model.establish_connection @options[:connection]
  end

  def validate(username, password)

  rescue ActiveRecord::RecordNotFound
    false
  end

  def load_user_data(username)

  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def option_initialize(options)
    unless options.respond_to?(:deep_symbolize_keys)
      raise ArgumentError, 'When assigning attributes, you must pass a hash as an argument.'
    end
    @options = options.deep_symbolize_keys
  end

  def validate_option_data
    raise ArgumentError, 'User Table name is missing' unless @options[:user_table]
    raise ArgumentError, 'OTP Table name is missing' unless @options[:otp_table]
  end

  def classify_table(table_name)
    if @options[:connection].kind_of?(Hash) && @options[:connection][:database]
      model_name = "#{@options[:connection][:database].gsub(/[^a-zA-Z]+/, '')}_#{table_name}"
    end
    model_name.classify
  end

  def load_class(model_class_name, table_name)
    eval <<-END
        class #{model_class_name} < AuthDatabase
          self.table_name = "#{table_name}"
          self.inheritance_column = :_type_disabled
        end
      END
  end
end
