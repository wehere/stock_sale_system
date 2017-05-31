threads 8,32
workers 1
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!

  require 'puma_worker_killer'

  PumaWorkerKiller.config do |config|
    config.ram           = 130 # mb
    config.frequency     = 5    # seconds
    config.percent_usage = 0.98
    config.rolling_restart_frequency = 12 * 3600 # 12 hours in seconds
    config.reaper_status_logs = true # setting this to false will not log lines like:
    # PumaWorkerKiller: Consuming 54.34765625 mb with master and 2 workers.

    config.pre_term = -> (worker) { puts "Worker #{worker.inspect} being killed" }
  end
  PumaWorkerKiller.start
end