# frozen_string_literal: true

require 'rdfconfig/jsonld'

require 'thor'

module Rdfconfig
  module Jsonld
    module CLI
      class Main < Thor
        include Thor::Actions

        class << self
          def exit_on_failure?
            true
          end
        end

        desc 'convert <FILE>', 'Convert to JSON-LD with RDF Config'
        option :config_dir, aliases: '-c', type: :string, required: true, desc: 'Path to config directory'
        option :format, aliases: '-f', type: :string, default: 'jsonl', enum: %w[jsonld json-ld json_ld jsonl rdf], desc: 'Output format'
        option :header_lines, aliases: '-h', type: :numeric, default: 1, desc: 'Number of header lines'
        option :lines, aliases: '-l', type: :numeric, default: 100, desc: 'Number of lines per batch'
        option :max_proc, aliases: '-p', type: :numeric, default: 1, desc: 'Maximum number of processes'
        option :output_dir, aliases: '-o', type: :string, default: Dir.pwd, desc: 'Path to output directory'
        option :file_prefix, type: :string, default: 'output', desc: 'Prefix of output file name'

        def convert(file)
          require 'rdfconfig/jsonld/cli/convert_helper'

          self.class.include(ConvertHelper)

          if options[:max_proc] > 1 && InputReader.from_path(file).lines_exceed?(options[:header_lines] + options[:lines])
            run_in_batch(file, **options.to_h)
          else
            convert_file(file, **options.to_h)
          end
        end

        desc 'version', 'Show version number'

        def version
          puts "#{File.basename($PROGRAM_NAME)} #{VERSION}"
        end

        map %w[--version -v] => :version

        desc 'console', 'Start interactive console', hide: true

        def console
          require 'irb'

          ARGV.clear

          Object.include(Rdfconfig::Jsonld)

          IRB.start(__FILE__)
        end
      end
    end
  end
end
