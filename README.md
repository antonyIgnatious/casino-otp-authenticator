INTRODUCTION

    Provides mechanism to use OTP as an authenticator for [CASino](https://github.com/rbCAS/CASino).

INSTALLATION
   
    add this to your Gemfile file:
      gem 'casino-otp_authenticator' ,git: 'https://github.com/antonyIgnatious/casino-otp_authenticator.git'

USAGE
    
    To use the OTP authenticator, configure it in your cas.yml:

    authenticators:
      my_company_sql:
        authenticator: "OTP"
        options:
          connection:
            adapter: "mysql2"
            host: "localhost"
            username: "casino"
            password: "secret"
            database: "users"
          user_table: "users"
          user_mobile_column: "user_mobile"
          otp_table: "otp_table"
          otp_mobile_column: "mobile_number"
          otp_value_column: "otp"
          extra_attributes:
            email: "email_column"
            fullname: "name_column"
