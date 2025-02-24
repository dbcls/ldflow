# frozen_string_literal: true

module Rdfconfig
  module Jsonld
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

          Jsonld.logger = Jsonld::Logger.new($stderr, level: ENV['LOG_LEVEL'] || ::Logger::INFO)

          require 'rdfconfig/jsonld/cli/convert_helper'

          self.class.include(ConvertHelper)

          if options[:max_proc] > 1 && Reader.from_path(file).lines_exceed?(options[:header_lines] + options[:lines])
            run_in_batch(file, **options.to_h)
          else
            convert_file(file, **options.to_h)
          end
        end

        desc 'jsonl <FILE>', 'Convert to JSON-LD with RDF Config'
        option :format, aliases: '-f', type: :string, default: 'ntriples', enum: %w[ntriples], desc: 'Output format'
        option :output, aliases: '-o', type: :string, default: '-', desc: 'Path to the output'
        option :preload, aliases: '-p', type: :string, desc: 'Path to a context file to preload'

        def jsonl(file)
          unless options[:output] == '-' || Dir.exist?((dir = File.dirname(options[:output])))
            abort "Directory not found: #{dir}"
          end

          require 'rdfconfig/jsonld/cli/convert_helper'

          self.class.include(ConvertHelper)

          case options[:format]
          when 'ntriples'
            jsonl_to_ntriples(file, **options.to_h)
          else
            raise Error, "Not supported format: #{options[:format]}"
          end
        end
      end
    end
  end
end
