Given /^(?:|I *) upload the spec file "([^"]*)" as "([^"]*)"$/ do |path, field|
  icon = page.find('#icon_file_upload')
  icon.click
  path = Rails.root.join('spec', 'attachments', path)
  attach_file(field, File.expand_path(path))
  if page.driver.respond_to? :console_messages
    error_msgs = page.driver.console_messages
    Rails.logger.info error_msgs.inspect
  end
end

