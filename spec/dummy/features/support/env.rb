# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'rubygems'

if defined?(IRB) && IRB.class.to_s == 'Class'
  Object.send(:remove_const, :IRB)
  require 'IRB'
  require 'IRB/init'
  require 'IRB/context'
  require 'IRB/extend-command'
  require 'IRB/locale'
end

begin
  ; require 'ruby-debug'
rescue LoadError => err;
  puts err;
end

begin
  ; require 'pry'
  if defined?(IRB) && IRB.class.to_s == 'Module'
    Object.send(:remove_const, :IRB)
    IRB = Pry
  end
rescue LoadError => err;
end

require 'cucumber/rails'

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

require 'cucumber/rails/world'

