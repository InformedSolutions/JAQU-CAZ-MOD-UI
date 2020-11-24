# frozen_string_literal: true

##
# This is an abstract class used as a base for all service classes.
class BaseService
  ##
  # Creates an instance of a service and calls its +call+ method passing all the arguments.
  #
  # ==== Attributes
  #
  # Accepts all arguments and passes them to the service initializer
  def self.call(**args)
    new(**args).call
  end

  # Logs exception on +error+ level
  def log_error(exception)
    Rails.logger.error "[#{self.class.name}] #{exception.class} - #{exception}"
  end

  # Logs msg on +info+ level
  def log_action(msg)
    Rails.logger.info "[#{self.class.name}] #{msg}"
  end
end
