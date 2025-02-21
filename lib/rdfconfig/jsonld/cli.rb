# frozen_string_literal: true

require 'rdfconfig/jsonld'

require 'thor'

module Rdfconfig
  module Jsonld
    module CLI
      require 'rdfconfig/jsonld/cli/convert'

      class Main < Thor
        include Thor::Actions

        class << self
          def exit_on_failure?
            true
          end
        end

        desc 'convert', 'Subcommands for file format conversion'

        subcommand 'convert', Convert

        desc 'version', 'Show version number'

        def version
          puts "#{File.basename($PROGRAM_NAME)} #{VERSION}"
        end

        map %w[--version -v] => :version

        desc 'console', 'Start interactive console', hide: true

        def console
          require 'irb'

          ARGV.clear

          Jsonld.logger = Jsonld::Logger.new($stderr, level: Jsonld::Logger::DEBUG)

          Object.include(Jsonld)

          IRB.start(__FILE__)
        end
      end
    end
  end
end
