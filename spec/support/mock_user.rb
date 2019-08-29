# frozen_string_literal: true

module MockUser
  def new_user(options = {})
    user = User.new
    options.each do |key, value|
      user.public_send("#{key}=", value)
    end
    user
  end
end
