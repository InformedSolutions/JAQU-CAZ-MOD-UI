# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

if Rails.env.production?
  defaults = %i[self https]

  Rails.application.config.content_security_policy do |policy|
    policy.default_src(:none)
    policy.font_src(*defaults, :data)
    policy.img_src(*defaults)
    policy.object_src(:none)
    policy.script_src(*defaults, :unsafe_inline)
    policy.style_src(*defaults, :unsafe_inline)
    policy.connect_src(*defaults)
    policy.frame_src('https://www.googletagmanager.com')
    policy.frame_ancestors(:none)
  end
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator =
# -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
