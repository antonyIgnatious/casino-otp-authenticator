# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'casino/otp_authenticator/version'

Gem::Specification.new do |s|
  s.name        = 'casino-otp_authenticator'
  s.version     = CASino::OtpAuthenticator::VERSION
  s.authors     = ['Antony Ignatious']
  s.email       = ['antonyignatious@ymail.com']
  s.homepage    = 'http://rbcas.org/'
  s.license     = 'MIT'
  s.summary     = 'Provides mechanism to use OTP as an authenticator for CASino.'
  s.description = 'This gem can be used authenticate otp based authorisation'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # s.add_development_dependency 'rake', '~> 10.0'
  # s.add_development_dependency 'rspec', '~> 2.12'
  # s.add_development_dependency 'simplecov', '~> 0.7'
  # s.add_development_dependency 'sqlite3', '~> 1.3.7'
  # s.add_development_dependency 'coveralls'

  s.add_runtime_dependency 'activerecord', '>= 4.1.0', '< 4.3.0'
  s.add_runtime_dependency 'casino', '>= 3.0.0', '< 5.0.0'
end
