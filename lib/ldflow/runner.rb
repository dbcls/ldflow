# frozen_string_literal: true

module Ldflow
  class Runner
    attr_reader :executor, :files, :options

    def initialize(executor, *files, **options)
      @executor = executor
      @files = files
      @options = options
    end

    def run
      Ldflow.logger.info { "Running tasks with #{executor.class.name.split('::')[-1]}" }
      Ldflow.logger.debug { "options: #{options}" }

      outputs = executor.execute(*files, **options)

      Ldflow.logger.info { "Merging #{outputs.size} outputs" }

      t = Benchmark.realtime do
        Writer.from_path(options[:output]) do |io|
          outputs.each do |path|
            io << File.read(path)
          end
        end
      end

      Ldflow.logger.info { "Merged outputs in #{t.readable_duration}" }
    end
  end
end
