# frozen_string_literal: true

# Modified Formatter class to remove IPs from logging
class CustomLogger < Logger::Formatter
  # https://www.oreilly.com/library/view/regular-expressions-cookbook/9780596802837/ch07s16.html
  IP_REGEX = /\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/.freeze
  FILTERED_STRING = '[REDACTED]'

  def call(severity, time, progname, msg)
    formatted_severity = format('%<sev>-5s', sev: severity.to_s)
    formatted_time = time.strftime('%Y-%m-%d %H:%M:%S')
    formatted_msg = filter_pii(msg)
    "[#{formatted_severity} #{formatted_time}] #{progname} #{formatted_msg}\n"
  end

  # If log string contains IP address then replace it with custom string
  def filter_pii(msg)
    msg.gsub(IP_REGEX, FILTERED_STRING)
  end
end
