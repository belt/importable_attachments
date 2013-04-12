require 'rails/generators/active_record/migration'

module ImportableAttachments
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)
    class_option :with_string_ids, type: :boolean, default: true, desc: 'versions.type_id as string (vs integer)'

    # paperclip-3.3.x seems to require this
    # paperclip-3.4.x seems to have broken this
    class_option :with_revision_in_filename, type: :boolean, default: false, desc: 'filename on system to include version-number'

    class_option :'skip-migrations', type: :boolean, default: false, desc: 'do not generate migrations'
    class_option :force, type: :boolean, default: false, desc: 'force generation migrations'

    desc 'Runs rspec:paper_trail:install'

    def generate_rspec_paper_trail_install
      return if options.send(:'skip-migrations')
      cli_opts = options.select { |k, v| v }.map { |k, v| v ? "--#{k}" : v.join(",") }
      cmd = 'rspec:paper_trail:install ' + cli_opts.join(" ")
      generate cmd
    end

    desc 'Generates updated rspec:paper_trail:install config'

    def generate_updated_rspec_paper_trail_config
      template 'features/versioning.rb', 'config/features/versioning.rb'
    end

    desc 'Runs smarter_dates:install'

    def generate_smarter_dates_install
      cli_opts = options.select { |k, v| v }.map { |k, v| v ? "--#{k}" : v.join(",") }
      generate 'smarter_dates:install ' + cli_opts.join(" ")
    end

    desc 'Generates initialization files.'

    def generate_configuration_files
      template 'features/attachments.rb.erb', 'config/features/attachments.rb'
      copy_file 'initializers/paperclip.rb', 'config/initializers/paperclip.rb'
    end

    desc 'Augments spec/spec_helper.rb for formtastic deployment'

    def augment_spec_helper
      insert_into_file 'config/environments/production.rb', '  config.assets.precompile += %w(ie6.css ie7.css)', after: "# config.assets.precompile += %w( search.js )\n"
    end

    private

    def use_versioned_filename?
      options.with_revision_in_filename?
    end
  end
end
