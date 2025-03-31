# frozen_string_literal: true

require 'dotenv'

module Ldflow
  class Middleware
    module Container
      ELASTICSEARCH = 'ldflow-elasticsearch'
      KIBANA = 'ldflow-kibana'
      SUPERSET_REDIS = 'ldflow-superset-redis'
      SUPERSET_DB = 'ldflow-superset-db'
      SUPERSET = 'ldflow-superset'
      SUPERSET_WORKER = 'ldflow-superset-worker'
      SUPERSET_WORKER_BEAT = 'ldflow-superset-worker-beat'
    end

    class << self
      def compose
        @compose ||= command(%w[docker compose >/dev/null 2>&1]) do |_, status|
          if status.success?
            break %w[docker compose]
          elsif available?('docker-compose')
            break %w[docker-compose]
          else
            raise 'Docker compose is not installed'
          end
        end
      end

      def version
        command(compose + ['version']).chomp
      end

      def env
        Dotenv.parse(Ldflow.home.join('.env'))
      end

      def check
        check_container_running
      end

      def setup
        init_superset
      end

      private

      def command(*cmds)
        out = `#{cmds.join(' ')}`
        status = $CHILD_STATUS

        yield [out, status] if block_given?

        out
      end

      def available?(cmd)
        command(['command', '-v', cmd, '>/dev/null']) do |_, status|
          break status.success?
        end
      end

      def check_container_running
        containers = command(%w[docker ps --format {{.Names}}]).each_line(chomp: true)

        running = Container.constants.map do |x|
          name = Container.const_get(x)
          containers.find { |c| c == name }&.tap { |c| puts "The docker container '#{c}' is already running." }
        end

        abort if running.any?
      end

      def init_superset
        admin_password = env['SS_PASSWORD']

        raise Error, 'SS_PASSWORD is not set' unless admin_password && !admin_password.empty?

        cmd = compose + [
          '-f', Ldflow.home.join('docker-compose.yml').to_s,
          'run',
          '--rm',
          '--user', 'root',
          '--env', %("ADMIN_PASSWORD=#{admin_password}"),
          'superset',
          '/app/docker/docker-init.sh'
        ]

        puts cmd.join(' ')

        system(cmd, exception: true)
      end
    end
  end
end
