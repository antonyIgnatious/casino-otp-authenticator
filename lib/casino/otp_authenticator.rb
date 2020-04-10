require 'active_record'

class CASino::OtpAuthenticator

  class AuthDatabase < ::ActiveRecord::Base
    self.abstract_class = true
  end

  def initialize(options)
    p "----"
    p "option"
    p options
    option_initialize(options)
    validate_option_data
    user_model_name = classify_table(@options[:user_table])
    otp_model_name = classify_table(@options[:otp_table])
    user_model_class_name = "#{self.class}::#{user_model_name}"
    otp_model_class_name = "#{self.class}::#{otp_model_name}"
    load_class(user_model_class_name, @options[:user_table])
    load_class(otp_model_class_name, @options[:otp_table])
    @user_model = user_model_class_name.constantize
    @otp_model = otp_model_class_name.constantize
    @user_model.establish_connection @options[:connection]
    @otp_model.establish_connection @options[:connection]
  end

  def validate(username, password)
    user_record = @user_model.send("find_by_#{@options[:user_email_column]}", username) ||
                  @user_model.send("find_by_#{@options[:user_mobile_column]}!", username)
    user_id = user_record.send('id')
    return false if user_id.blank?
    otp_record = @otp_model.where("#{@options[:otp_token_record_id_column]}": user_id)
                           .where("#{@options[:otp_token_record_type_column]}": 'UserAccount')
    return false if otp_record.blank?
    otp_record = otp_record.first
    password_from_database = otp_record.send(@options[:otp_value_column])
    return false if password_from_database.blank?
    if password == password_from_database && verify_otp(otp_record)
      user_data(user_record)
    else
      false
    end
  rescue ActiveRecord::RecordNotFound
    false
  end

  def load_user_data(username)
    user = @user_model.send("find_by_#{@options[:user_mobile_column]}", username) ||
           @user_model.send("find_by_#{@options[:user_email_column]}!", username)
    user_data(user)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def verify_otp(otp_record)
    if otp_record.send(@options[:expiry_column]) > Time.zone.now && otp_record.send(@options[:resend_column])&.to_i <= @options[:resend_limit].to_i
      otp_record.destroy!
    elsif otp_record.send(@options[:expiry_column]) < Time.zone.now
      false
    elsif otp_record.resend_count&.to_i > @options[:resend_limit].to_i
      false
    end
  end

  def user_data(user)
    { username: user.send(@options[:user_mobile_column]), extra_attributes: extra_attributes(user) }
  end

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
    if @options[:connection].is_a?(Hash) && @options[:connection][:database]
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

  def extra_attributes(user)
    attributes = {}
    extra_attributes_option.each do |attribute_name, database_column|
      attributes[attribute_name] = user.send(database_column)
    end
    attributes
  end

  def extra_attributes_option
    @options[:extra_attributes] || {}
  end
end
