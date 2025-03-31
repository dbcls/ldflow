# frozen_string_literal: true

require 'ldflow'

require 'dotenv'
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

        def source_root
          File.expand_path('lib/ldflow/templates', Ldflow::GEM_ROOT)
        end
      end

      desc 'setup', 'Setup ldflow'

      option :force, aliases: '-f', type: :boolean, desc: 'Overwrite files that already exist'
      option :pretend, aliases: '-p', type: :boolean, desc: 'Run but do not make any changes'

      option :elasticsearch, type: :string, default: '8.17.4', desc: 'Elasticsearch version'
      option :superset, type: :string, default: '4.1.2', desc: 'Superset version'

      option :kibana, type: :boolean, default: false, desc: 'Enable kibana'
      option :nodes, type: :numeric, default: 1, desc: 'Number of elasticsearch nodes'
      option :superset_examples, type: :boolean, desc: 'Load examples to superset'

      def setup
        puts Middleware.version

        Middleware.check unless options[:pretend]

        if (env_file = Ldflow.home.join('.env')).exist?
          env = Dotenv.parse(env_file)
          @elasticsearch_password = env['ES_PASSWORD'] if env['ES_PASSWORD'] && !env['ES_PASSWORD'].empty?
          @kibana_password = env['KIBANA_PASSWORD'] if env['KIBANA_PASSWORD'] && !env['KIBANA_PASSWORD'].empty?
          @superset_password = env['SS_PASSWORD'] if env['SS_PASSWORD'] && !env['SS_PASSWORD'].empty?
        end

        @elasticsearch_password ||= SecureRandom.alphanumeric
        @kibana_password ||= SecureRandom.alphanumeric
        @superset_password ||= SecureRandom.alphanumeric

        @options = options

        empty_directory Ldflow.home

        template 'env.erb', Ldflow.home.join('.env'), context: binding
        template 'docker-compose.yml.erb', Ldflow.home.join('docker-compose.yml'), context: binding

        directory File.expand_path('vendor/superset/docker', Ldflow::GEM_ROOT), Ldflow.home.join('docker'), mode: :preserve
        copy_file 'requirements-local.txt', Ldflow.home.join('docker', 'requirements-local.txt')
        template 'superset.env.erb', Ldflow.home.join('docker', '.env-local'), context: binding

        Middleware.setup unless options[:pretend]
      end

      desc 'compose', 'Subcommands for docker compose'

      def compose(*args)
        cmd = Middleware.compose + ['-f', Ldflow.home.join('docker-compose.yml').to_s] + args

        run cmd.join(' ')
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
