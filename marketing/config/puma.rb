# vim: ft=ruby
require 'semantic_logger'
require 'puma/dsl'

# Set the global default log level
SemanticLogger.default_level = :trace
SemanticLogger.add_appender(io: $stdout, formatter: :color)
SemanticLogger.application = "bashmatic"
SemanticLogger.environment = "development"
SemanticLogger.backtrace_level = :debug

LOGGER = SemanticLogger['bashmatic']

log_requests true

custom_logger = SemanticLogger
log_writer = Puma::LogWriter.new(STDOUT, STDERR)
log_writer.custom_logger = custom_logger

bind 'tcp://0.0.0.0:3001'
enable_keep_alives true
early_hints nil
environment 'development'.freeze
io_selector_backend :auto

threads 1,6
workers 0

queue_requests true
rackup 'config.ru'.freeze

tag 'bashmatic'

wait_for_less_busy_worker 0.005
worker_boot_timeout 60
worker_check_interval 5
worker_culling_strategy :youngest
worker_shutdown_timeout 30
worker_timeout 60

http_content_length_limit nil
