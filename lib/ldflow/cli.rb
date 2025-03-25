# frozen_string_literal: true

require 'ldflow'

require 'thor'

module Ldflow
  module CLI
    require 'ldflow/cli/convert'

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

        Ldflow.logger = Ldflow::Logger.new($stderr, level: Ldflow::Logger::DEBUG)

        Object.include(Ldflow)

        IRB.start(__FILE__)
      end
    end
  end
end
