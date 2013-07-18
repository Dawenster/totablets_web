# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Totablets::Application.initialize!

# Taxes to tax
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tax', 'taxes'
  inflect.singular 'taxes', 'tax'
end