app_dir = File.expand_path("../..", __FILE__)
rackup(File.expand_path('../config.ru', __dir__))
shared_dir = "#{app_dir}"
if ENV['RACK_ENV'] == 'development'
  workers 0
  environment 'development'
else
  require 'puma/daemon'
  environment 'production'
  workers Integer(ENV['WEB_CONCURRENCY'] || 22)
  daemonize
  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
end

threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads 1, threads_count

preload_app!

# port        ENV['PORT']     || 3000
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
pidfile "#{shared_dir}/tmp/pids/puma.pid"


