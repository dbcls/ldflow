# frozen_string_literal: true

require 'parallel'

module Rdfconfig
  module Jsonld
    module Strategy
      class DefaultExecutor
        def initialize(*files)
          @files = files
        end

        CLI_OPTIONS = %i[config_dir format output_dir file_prefix].freeze
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
          options = options.dup

          lambda do |file|
            options[:output_dir] = File.basename(file, File.extname(file))

            CLI::Main.new([file], options.slice(*CLI_OPTIONS)).invoke(:convert)

            File.join(options[:output_dir], "#{options[:file_prefix]}#{Jsonld.output_rdf_extension(options[:format])}")
          end
        end
      end
    end
  end
end
