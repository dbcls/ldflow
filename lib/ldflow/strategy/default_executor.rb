# frozen_string_literal: true

require 'parallel'

module Ldflow
  module Strategy
    class DefaultExecutor
      def initialize(name, **options)
        options = options.transform_keys(&:to_sym)

        @name = name
        @parallel = options[:max_proc] && options[:max_proc] > 1
        @processes = options[:max_proc]
        @cli_options = options[:cli] || {}
      end

      # @return [Array<String>] path to output files
      def execute(*files, **_options)
        if @parallel
          Parallel.map(files, in_processes: @processes, &process)
        else
          files.map(&process)
        end
      end

      private

      def process
        lambda do |f|
          output = File.join('out', File.basename(f))
          args = [[f], @cli_options.merge(output:)]

          CLI::Convert.new.invoke(@name, *args)

          output
        end
      end
    end
  end
end
