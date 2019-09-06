# frozen_string_literal: true

class BaseService
  def self.call(**args)
    new(args).call
  end

  def log_error(exception)
    Rails.logger.error "[#{self.class.name}] #{exception.class} - #{exception}"
  end

  def log_action(msg)
    Rails.logger.info "[#{self.class.name}] #{msg}"
  end
end
