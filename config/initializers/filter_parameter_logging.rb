# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[password confirmation_code]

# https://github.com/aws/aws-sdk-ruby/issues/2122
module Aws
  module Log
    class ParamFilter
      def filter_hash(values)
        filtered = {}
        values.each_pair do |key, value|
          key = key.downcase.to_sym
          filtered[key] = @filters.include?(key) ? '[FILTERED]' : filter(value)
        end
        filtered
      end
    end
  end
end
