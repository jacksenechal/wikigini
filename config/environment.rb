# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WikiGini::Application.initialize!

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '3.0.3' unless defined? RAILS_GEM_VERSION
