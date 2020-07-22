require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG
$logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity}: #{msg}\n"
end