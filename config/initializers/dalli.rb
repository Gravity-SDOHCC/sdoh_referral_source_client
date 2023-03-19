require 'dalli'

if Rails.env.production?
  # Heroku memcachier addon
  memcached_config = {
    username: ENV['MEMCACHIER_USERNAME'],
    password: ENV['MEMCACHIER_PASSWORD'],
    servers: (ENV["MEMCACHIER_SERVERS"] || "").split(","),
    failover: true,
    socket_timeout: 1.5,
    socket_failure_delay: 0.2,
    down_retry_delay: 60
  }

  Rails.application.config.cache_store = :dalli_store, *memcached_config.values, { namespace: 'production', expires_in: 1.day, compress: true }
else
  Rails.application.config.cache_store = :dalli_store, '127.0.0.1:11211', { namespace: 'dev', expires_in: 1.day, compress: true }
end

Rails.application.config.session_store :cache_store, key: '_ehr_rails_app_session', expire_after: 30.minutes
