# frozen_string_literal: true

require 'zlib'

module Rdfconfig
  module Jsonld
    class Runner
      attr_reader :executor, :files, :options

      def initialize(executor, *files, **options)
        @executor = executor
        @files = files
        @options = options
      end

      def run
        Jsonld.logger.info { "Running tasks with #{executor.class.name.split('::')[-1]}" }
        Jsonld.logger.debug { "options: #{options}" }

        outputs = executor.execute(*files, **options)

        Jsonld.logger.info { "Merging #{outputs.size} outputs" }

        t = Benchmark.realtime do
          Writer.from_path(options[:output]) do |io|
            outputs.each do |path|
              io << File.read(path)
            end
          end
        end

        Jsonld.logger.info { "Merged outputs in #{t.readable_duration}" }
      end
    end
  end
end
