# frozen_string_literal: true

require 'zlib'

module Rdfconfig
  module Jsonld
    class Runner
      attr_reader :executor, :options

      def initialize(executor, **options)
        @executor = executor
        @options = options
      end

      # @return [String] path to merged output
      def run
        Jsonld.logger.info { "Running tasks with #{executor.class.name.split('::')[-1]}" }
        Jsonld.logger.debug { "options: #{options}" }

        outputs = @executor.execute(**@options)

        Jsonld.logger.info { "Merging #{outputs.size} outputs" }

        output = "#{options[:file_prefix]}#{Jsonld.output_rdf_extension(options[:format])}.gz"
        t = Benchmark.realtime do
          Zlib::GzipWriter.open(output) do |gz|
            outputs.each do |path|
              gz << File.read(path)
            end
          end
        end

        Jsonld.logger.info { "Merged outputs in #{t.readable_duration}" }

        output
      end
    end
  end
end
