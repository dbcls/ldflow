# frozen_string_literal: true

require 'parallel'

module Rdfconfig
  module Jsonld
    module Strategy
      class DefaultExecuter
        def initialize(*files, **options)
          @files = files
          @options = options
        end

        CLI_OPTIONS = %i[config_dir format output_dir file_prefix].freeze
        private_constant :CLI_OPTIONS

        # @return [Array<String>] path to output files
        def execute
          options = @options.dup

          block = lambda do |file|
            options[:output_dir] = File.basename(file, File.extname(file))

            command = CLI::Main.new([file], options.slice(*CLI_OPTIONS))
            command.invoke(:convert)

            File.join(options[:output_dir], "#{options[:file_prefix]}#{Jsonld.output_rdf_extension(options[:format])}")
          end

          if (max_proc = options[:max_proc] || 1) && max_proc.positive?
            Parallel.map(@files, in_processes: max_proc, &block)
          else
            @files.map(&block)
          end
        end
      end
    end
  end
end
