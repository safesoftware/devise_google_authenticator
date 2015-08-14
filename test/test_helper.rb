ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym

$:.unshift File.dirname(__FILE__)
puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}"
require "rails_app/config/environment"
include Devise::TestHelpers
require "orm/#{DEVISE_ORM}"
require 'rails/test_help'
require 'capybara/rails'
require 'timecop'
require 'debugger'
require 'database_cleaner'

I18n.load_path << File.expand_path("../support/locale/en.yml", __FILE__) if DEVISE_ORM == :mongoid

DatabaseCleaner.strategy = :transaction

ActiveSupport::Deprecation.silenced = true

class ActionDispatch::IntegrationTest
  include Capybara::DSL
end
class ActionController::TestCase
	include Devise::TestHelpers
end

class ActiveSupport::TestCase
  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false
  setup { DatabaseCleaner.start }
  teardown { DatabaseCleaner.clean }
end
