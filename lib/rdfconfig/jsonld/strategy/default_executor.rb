# frozen_string_literal: true

require 'parallel'

module Rdfconfig
  module Jsonld
    module Strategy
      class DefaultExecutor
        def initialize(*files)
          @files = files
        end

        CLI_OPTIONS = %i[config_dir format header_lines lines].freeze
        private_constant :CLI_OPTIONS

        # @return [Array<String>] path to output files
        def execute(**options)
          if (max_proc = options[:max_proc] || 1) && max_proc.positive?
            Parallel.map(@files, in_processes: max_proc, &process(**options))
          else
            @files.map(&process(**options))
          end
        end

        private

        def process(**options)
          lambda do |file|
            file_name = File.basename(file, File.extname(file))
            ext = Jsonld.output_rdf_extension(options[:format])
            output = File.join('out', "#{file_name}#{ext}")

            opts = options.slice(*CLI_OPTIONS).merge(output:)

            CLI::Convert.new.invoke(:table, :table, [file], opts)

            output
          end
        end
      end
    end
  end
end
