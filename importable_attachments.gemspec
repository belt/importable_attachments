# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'importable_attachments/version'
#Bundler.require(:default, :development)

REQUIREMENTS = {
  runtime: {
    :'haml-rails' => ['~> 0.4'],
    paper_trail: ['~> 2.7.1'],
    paperclip: ['~> 3.4.2'],
    configuration: ['~> 1.3.2'],
    smarter_dates: ['~> 0.2.15'],
    :'ruby-filemagic' => ['~> 0.4.2'],
    :'rspec-paper_trail' => ['~> 0.0.10'],
    :'rails-mark_requirements' => ['~> 0.0.1'],
    :'rails-alpha_numeric_validator' => ['~> 0.1.1'],
    formtastic: ['~> 2.2.1'],
    remotipart: ['~> 1.0.5'],
    roo: ['~> 1.11.2'],
    rails: ['~> 3.2.13'],
    :'activerecord-import' => ['~> 0.3.1'],
    :'coffee-script' => ['~> 2.2.0'],
    :'coffee-rails' => ['~> 3.2.2'] }, # coffee-rails is needed for <= 3.0.x
  development: {
    bundler: ['~> 1.3.0'],
    rake: ['>= 0'],
    sqlite3: ['~> 1.3.7'],
    debugger: ['~> 1.5.0'],
    rspec: ['~> 2.13.0'],
    mocha: ['~> 0.13.0'],
    database_cleaner: ['~> 1.0.1'],
    machinist: ['~> 2.0.0'],
    :'rspec-rails' => ['~> 2.13.0'],
    :'cucumber-rails' => ['~> 1.3.1'],
    poltergeist: ['< 1.1.0'],
    capybara: ['< 2.0.0'],
    launchy: ['~> 2.3.0'],
    valid_attribute: ['~> 1.3.1'] }
}

Gem::Specification.new do |spec|
  spec.name          = 'importable_attachments'
  spec.version       = ImportableAttachments::VERSION
  spec.authors       = ['Paul Belt']
  spec.email         = %w(saprb@channing.harvard.edu)
  spec.description   = %q{Easier upload management for ActiveRecord}
  spec.summary       = %q{upload, save-to-disk, attach-to-model_instance, importing}
  spec.homepage      = 'https://github.com/belt/importable_attachments'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.requirements = %w(libmagic)
  spec.required_ruby_version = Gem::Requirement.new('>= 1.9.2')
  spec.required_rubygems_version = Gem::Requirement.new('>= 0') if spec.respond_to? :required_rubygems_version=

  [:runtime, :development].each do |mode|
    REQUIREMENTS[mode].each do |req,ver|
      if spec.respond_to? :specification_version
        spec.specification_version = 3
        if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
          if mode == :runtime
            spec.add_runtime_dependency req.to_s, ver
          else
            spec.add_development_dependency req.to_s, ver
          end
        else
          spec.add_dependency req.to_s, ver
        end
      else
        spec.add_dependency req.to_s, ver
      end
    end
  end

end
