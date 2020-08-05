# frozen_string_literal: true

#
# Stop logging 'Nothing to do' in rails console and logs
# Generated every time Webpacker::Compiler#compile is called on non stale compiled packs
# TO DO: Remove when changes will be introduced
# https://github.com/rails/webpacker/issues/2392
# :nocov:
Webpacker::Compiler.class_eval do
  def compile
    if stale?
      run_webpack.tap do |_success|
        record_compilation_digest
      end
    else
      true
    end
  end
end
# :nocov:
