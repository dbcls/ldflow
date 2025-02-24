# frozen_string_literal: true

require 'tmpdir'
require 'csv'

module Rdfconfig
  module Jsonld
    module CLI
      module ConvertHelper
        def run_in_batch(file, **options)
          options = options.transform_keys(&:to_sym)

          input = File.expand_path(file)
          output = File.expand_path(options[:output])
          config_dir = File.expand_path(options[:config_dir])

          t = Benchmark.realtime do
            Dir.mktmpdir do |dir|
              Jsonld.logger.debug { "Created temporary directory: #{dir}" }

              inside dir do
                empty_directory 'out', verbose: false

                Jsonld.logger.info { "Splitting the input file into #{options[:lines]} lines per file" }

                files = Reader.from_path(input).split(header_lines: options[:header_lines],
                                                      lines: options[:lines],
                                                      prefix: 'chunk_')

                Jsonld.logger.info { "Split into #{files.size} files" }

                Runner.new(Strategy::DefaultExecutor.new(*files), **options, config_dir:, output:).run
              end
            end
          end

          Jsonld.logger.info { "Wrote to #{options[:output]}" }

          Jsonld.logger.info { "Converted #{file} in #{t.readable_duration}" }
        end

        def convert_file(file, **options)
          options = options.transform_keys(&:to_sym)

          Jsonld.rdf_config_convert(file, **options) do |conv|
            t = Benchmark.realtime do
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

            Jsonld.logger.info { "Converted #{file} in #{t.readable_duration}" }
          end
        end

        def jsonl_to_ntriples(file, **options)
          require 'json'
          require 'json/ld'
          require 'rdf'
          require 'rdf/ntriples'

          options = options.transform_keys(&:to_sym)

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

          Jsonld.logger.info { "Converted #{file} in #{t.readable_duration}" }
        end
      end
    end
  end
end
