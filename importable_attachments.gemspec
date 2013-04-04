# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'importable_attachments/version'
#Bundler.require(:default, :development)

REQUIREMENTS = {
  runtime: {
    :'haml-rails' => ['>= 0.4'],
    paper_trail: ['>= 2.7.1'],
    paperclip: ['>= 3.4.1'],
    configuration: ['>= 1.3.2'],
    smarter_dates: ['>= 0.2.9'],
    :'rspec-paper_trail' => ['>= 0.0.9'],
    :'rails-mark_requirements' => ['>= 0.0.1'],
    :'rails-alpha_numeric_validator' => ['>= 0.0.1'],
    rails: ['~> 3.2.13'] },
  development: {
    bundler: ['~> 1.3'],
    rake: ['>= 0'],
    sqlite3: ['>= 1.3.7'],
    debugger: ['>= 1.5.0'],
    rspec: ['>= 2.13.0'],
    mocha: ['>= 0.13.0'],
    database_cleaner: ['>= 0.9.1'],
    machinist: ['>= 2.0.0'],
    :'rspec-rails' => ['>= 2.12.0'],
    valid_attribute: ['>= 1.3.1'] }
}

Gem::Specification.new do |spec|
  spec.name          = 'importable_attachments'
  spec.version       = ImportableAttachments::VERSION
  spec.authors       = ['Paul Belt']
  spec.email         = %w(saprb@channing.harvard.edu)
  spec.description   = %q{Easier upload management for ActiveRecord}
  spec.summary       = %q{upload, save-to-disk, attach-to-model_instance, importing}
  spec.homepage      = 'http://drdev2.bwh.harvard.edu:8000/'
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
