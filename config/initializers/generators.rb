Rails.application.config.generators do |g|
  g.view_specs false
  g.helper_specs false
  g.test_framework :rspec
  g.fixture_replacement :machinist
  g.orm :active_record
  g.template_engine :haml
  g.stylesheet_engine :sass
end

