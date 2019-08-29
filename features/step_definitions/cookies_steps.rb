# frozen_string_literal: true

# Scenario: User see cookies page
When('I press Cookies link') do
  within('footer.govuk-footer') do
    click_link 'Cookies'
  end
end
