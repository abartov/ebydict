workers Integer(ENV['WEB_CONCURRENCY'] || 3)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads 1, threads_count

directory(File.expand_path('..', __dir__))
rackup(File.expand_path('../config.ru', __dir__))
preload_app!

# port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'production'
app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}"
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
bind "unix://#{shared_dir}/tmp/sockets/puma.sock"
pidfile "#{shared_dir}/tmp/pids/puma.pid"


