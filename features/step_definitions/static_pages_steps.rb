# frozen_string_literal: true

When('I press {string} footer link') do |string|
  within('footer.govuk-footer') do
    click_link string
  end
end
