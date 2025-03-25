# frozen_string_literal: true

require_relative 'lib/ldflow/version'

Gem::Specification.new do |spec|
  spec.name = 'ldflow'
  spec.version = Ldflow::VERSION
  spec.authors = ['Daisuke Satoh']
  spec.email = ['dsatoh@kamonohashi.co.jp']

  spec.summary = 'JSON-LD RDF converter and loader'
  spec.description = spec.summary
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files --recurse-submodules -z`.split("\x0").reject do |f|
      f = f.delete_prefix('vendor/rdf-config/')
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json-ld', '~> 3.3'
  spec.add_dependency 'parallel', '~> 1.26'
  spec.add_dependency 'thor', '~> 1.2'

  # Dependencies listed in rdf-config's Gemfile
  spec.add_dependency 'parslet', '~> 2.0'
  spec.add_dependency 'rdf', '~> 3.3'
  spec.add_dependency 'rdf-turtle', '~> 3.3'
  spec.add_dependency 'rdf-xsd', '~> 3.3'
  spec.add_dependency 'rexml', '~> 3.4'
end
