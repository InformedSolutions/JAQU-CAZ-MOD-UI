# frozen_string_literal: true

timeout_in_mins = Rails.configuration.x.session_timeout_in_min.minutes
Rails.application.config.session_store :cookie_store,
                                       key: '_csv_uploader_session',
                                       expire_after: timeout_in_mins,
                                       same_site: :strict
