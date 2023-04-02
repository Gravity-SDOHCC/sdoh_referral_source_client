require_relative "boot"

require "rails/all"
# require 'dalli'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SdohReferralSourceClient
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    # set the cache store and session store
    config.cache_store = :mem_cache_store #, 'localhost', '127.0.0.1:11211'
    # config.session_store = :cache_store, { key: '_ehr_rails_app_session', expire_after: 30.minutes }


    # Enable fragment and page caching in ActionController
    config.action_controller.perform_caching = true
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
