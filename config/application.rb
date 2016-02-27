require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require 'yaml'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShengxingSystem
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.time_zone = 'Beijing'
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.default_options = {from: 'message@591order.com'}
    mail_config = YAML.load(File.open(Rails.root.join('config/config.yml')))
    puts "******"*10
    config.action_mailer.smtp_settings = {
        :address              => mail_config["mail"]["address"],
        :port                 => mail_config["mail"]["port"],
        :user_name            => mail_config["mail"]["user_name"],
        :password             => mail_config["mail"]["password"],
        :authentication       => 'plain',
        :enable_starttls_auto => true
    }


    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.active_job.queue_adapter = :delayed_job

    require Rails.root.join('lib/tool.rb')
  end
end
