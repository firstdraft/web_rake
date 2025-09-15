require_relative 'lib/web_rake/version'

Gem::Specification.new do |spec|
  spec.name        = 'web_rake'
  spec.version     = WebRake::VERSION
  spec.authors     = ['Ben Purinton']
  spec.email       = ['ben@firstdraft.com']
  spec.homepage    = 'https://github.com/firstdraft/web_rake'
  spec.summary     = 'Web interface for running Rake tasks'
  spec.description = 'A Rails engine that provides a web interface for discovering and running Rake tasks with HTTP basic authentication'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'rails', '>= 7.0.0'

  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'sqlite3'
end
