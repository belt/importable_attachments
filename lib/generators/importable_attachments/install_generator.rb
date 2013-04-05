require 'rails/generators/active_record/migration'

module ImportableAttachments
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    # paperclip-3.3.x seems to require this
    # paperclip-3.4.x seems to have broken this
    class_option :with_revision_in_filename, type: :boolean, default: false, desc: 'filename on system to include version-number'

    class_option :'skip-migrations', type: :boolean, default: false, desc: 'do not generate migrations'
    class_option :force, type: :boolean, default: false, desc: 'force generation migrations'

    desc 'Generates (but does not run) a migration to add attachments and versions tables.'

    def generate_migration_file
      return if options.send(:'skip-migrations')
      migration_template 'migrations/create_attachments.rb', 'db/migrate/create_attachments.rb'
    end

    desc 'Generates initialization files.'

    def generate_configuration_files
      cli_opts = options.select { |k, v| v }.map { |k, v| v ? "--#{k}" : v.join(",") }
      copy_file 'initializers/paperclip.rb', 'config/initializers/paperclip.rb'
    end

    desc 'Augments spec/spec_helper.rb adding paperclip and rspec-extensions'

    def augment_spec_helper
      ['config.include Paperclip::Shoulda::Matchers'].each do |line|
        insert_into_file 'spec/spec_helper.rb', "  #{line}\n", after: "RSpec.configure do |config|\n"
      end
      ["require \'paperclip/matchers\'"].each do |line|
        insert_into_file 'spec/spec_helper.rb', "#{line}\n", before: "RSpec.configure do |config|\n"
      end
      insert_into_file 'config/environments/production.rb', '  config.assets.precompile += %w(ie6.css ie7.css)', after: "# config.assets.precompile += %w( search.js )\n"
    end

    private

    def use_versioned_filename?
      options.with_revision_in_filename?
    end
  end
end
