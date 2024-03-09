# This configuration is optimized for running on limited resources, such as a Raspberry Pi.

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# In a resource-constrained environment like a Raspberry Pi, it's better to limit the number of workers.
# Too many workers can lead to excessive memory usage.
# We'll set a sensible default that can be overridden with an environment variable.
if ENV["RAILS_ENV"] == "production"
  # Limit the number of workers to a lower number suitable for a Raspberry Pi's resources.
  # 2 is a sensible default for a Raspberry Pi but consider adjusting based on your specific model and available resources.
  default_worker_count = 1
  workers ENV.fetch("WEB_CONCURRENCY") { default_worker_count }
end

# Since Raspberry Pi's resources are limited, we keep the worker timeout as is,
# but you might adjust it based on your application's needs.
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Use the default port or one specified by the PORT environment variable.
port ENV.fetch("PORT") { 3000 }

# Set the environment based on RAILS_ENV with a default of 'development'.
environment ENV.fetch("RAILS_ENV") { "development" }

# Define the pidfile location. Adjust the base directory if necessary.
base_directory = File.expand_path('../../', __FILE__)
default_pidfile_path = File.join(base_directory, 'tmp', 'pids', 'puma.pid') # Ensure the 'pids' directory exists or adjust as needed.
pidfile ENV.fetch("PIDFILE") { default_pidfile_path }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
