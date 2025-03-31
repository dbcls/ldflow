# frozen_string_literal: true

module Ldflow
  module CLI
    class Convert < Thor
      include Thor::Actions

      class << self
        def exit_on_failure?
          true
        end
      end

      desc 'table <FILE>', 'Convert table format data to RDF with RDF Config'
      option :config_dir, aliases: '-c', type: :string, required: true, desc: 'Path to config directory'
      option :format, aliases: '-f', type: :string, default: 'jsonl', enum: %w[jsonld json-ld json_ld jsonl rdf],
             desc: 'Output format'
      option :header_lines, aliases: '-L', type: :numeric, default: 1, desc: 'Number of header lines'
      option :lines, aliases: '-l', type: :numeric, default: 100, desc: 'Number of lines per batch'
      option :max_proc, aliases: '-p', type: :numeric, default: 1, desc: 'Maximum number of processes'
      option :output, aliases: '-o', type: :string, default: '-', desc: 'Path to the output'

      def table(file)
        abort '--header-lines=N must be greater than or equal to 1' unless options[:header_lines] >= 1
        abort '--lines=N must be greater than or equal to 1' unless options[:lines] >= 1
        abort '--max-proc=N must be greater than or equal to 1' unless options[:max_proc] >= 1

        unless options[:output] == '-' || Dir.exist?((dir = File.dirname(options[:output])))
          abort "Directory not found: #{dir}"
        end

        Ldflow.logger = Ldflow::Logger.new($stderr, level: ENV['LOG_LEVEL'] || ::Logger::INFO)

        require 'ldflow/cli/convert_helper'

        self.class.include(ConvertHelper)

        if options[:max_proc] > 1 && Reader.from_path(file).lines_exceed?(options[:header_lines] + options[:lines])
          opts = options.slice(:config_dir, :format, :header_lines, :lines)
          opts[:config_dir] = File.expand_path(options[:config_dir])

          executor = Strategy::DefaultExecutor.new(:table, **options, cli: opts)

          run_in_batch(file, executor, **options.to_h)
        else
          Ldflow.logger.info { "Converting #{file} to #{options[:format]}" }

          t = Benchmark.realtime do
            RdfConfigProxy.new(File.expand_path(options[:config_dir])).convert(file, **options) do |conv|
              Writer.from_path(options[:output]) do |f|
                sync = $stdout.sync

                File.open(File::NULL, 'w') do |null|
                  $stderr = null
                  $stdout = f

                  $stdout.sync = true if f.is_a?(Zlib::GzipWriter)

                  conv.generate
                ensure
                  $stdout = STDOUT
                  $stderr = STDERR
                  $stdout.sync = sync
                end
              end
            end
          end

          Ldflow.logger.info { "Converted #{file} in #{t.readable_duration}" }
        end
      end

      desc 'jsonl <FILE>', 'Convert JSON-LD lines to other RDF formats'
      option :format, aliases: '-f', type: :string, default: 'ntriples', enum: %w[ntriples], desc: 'Output format'
      option :lines, aliases: '-l', type: :numeric, default: 10_000, desc: 'Number of lines per batch'
      option :max_proc, aliases: '-p', type: :numeric, default: 1, desc: 'Maximum number of processes'
      option :output, aliases: '-o', type: :string, default: '-', desc: 'Path to the output'
      option :preload, type: :string, desc: 'Path to a context file to preload'

      def jsonl(file)
        abort '--lines=N must be greater than or equal to 1' unless options[:lines] >= 1
        abort '--max-proc=N must be greater than or equal to 1' unless options[:max_proc] >= 1
        abort '--preload is required for multi process' if options[:max_proc] > 1 && !options[:preload]

        unless options[:output] == '-' || Dir.exist?((dir = File.dirname(options[:output])))
          abort "Directory not found: #{dir}"
        end

        Ldflow.logger = Ldflow::Logger.new($stderr, level: ENV['LOG_LEVEL'] || ::Logger::INFO)

        require 'ldflow/cli/convert_helper'

        require 'json'
        require 'json/ld'
        require 'rdf'
        require 'rdf/ntriples'

        self.class.include(ConvertHelper)

        if options[:max_proc] > 1 && Reader.from_path(file).lines_exceed?(options[:lines])
          opts = options.slice(:format, :lines, :preload)
          opts[:preload] = File.expand_path(options[:preload]) if options[:preload]

          executor = Strategy::DefaultExecutor.new(:jsonl, **options, cli: opts)

          run_in_batch(file, executor, **options.to_h)
        else
          if options[:preload] && File.exist?(options[:preload])
            ctx = File.open(options[:preload]) do |f|
              JSON::LD::Context.new.parse(f)
            end
            JSON::LD::Context.add_preloaded(File.basename(options[:preload]), ctx)
          end

          output = options[:output] == '-' ? '-' : File.expand_path(options[:output])

          t = Benchmark.realtime do
            inside File.dirname(file) do
              Reader.from_path(File.basename(file)) do |f|
                Writer.from_path(output) do |io|
                  f.each_line do |line|
                    graph = RDF::Graph.new
                    graph << JSON::LD::API.toRdf(JSON.parse(line))
                    io << graph.dump(options[:format].to_sym)
                  end
                end
              end
            end
          end

          Ldflow.logger.info { "Converted #{file} in #{t.readable_duration}" }
        end
      end
    end
  end
end
