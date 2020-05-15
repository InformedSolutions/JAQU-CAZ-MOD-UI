# frozen_string_literal: true

# :nocov:
module Aws
  module Plugins
    class Logging < Seahorse::Client::Plugin
      class Handler < Seahorse::Client::Handler
        private

        # Do not log AWS::SES response by the reason that we should not see user email
        # TO DO: Modify response to log it without user email
        def log(config, response)
          return if config.sigv4_signer.service == 'ses'

          config.logger.send(config.log_level, format(config, response))
        end
      end
    end
  end
end
# :nocov:
