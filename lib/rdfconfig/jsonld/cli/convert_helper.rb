# frozen_string_literal: true

require 'tmpdir'
require 'csv'

module Rdfconfig
  module Jsonld
    module CLI
      module ConvertHelper
        def run_in_batch(file, executer, **options)
          options = options.transform_keys(&:to_sym)

          input = File.expand_path(file)
          output = File.expand_path(options[:output])

          ext = File.extname(file)
          ext = File.extname(File.basename(file, ext)) if ext == '.gz'

          t = Benchmark.realtime do
            Dir.mktmpdir do |dir|
              Jsonld.logger.debug { "Created temporary directory: #{dir}" }

              inside dir do
                empty_directory 'out', verbose: false

                Jsonld.logger.info { "Splitting the input file into #{options[:lines]} lines per file" }

                files = Reader.from_path(input).split(**options, prefix: 'chunk_', suffix: ext)

                Jsonld.logger.info { "Split into #{files.size} files" }
                Jsonld.logger.debug { "#{files.take(3).join(', ')} #{'...' if files.size > 3}" }

                Runner.new(executer, *files, **options, output:).run
              end
            end
          end

          Jsonld.logger.info { "Wrote to #{options[:output]}" }

          Jsonld.logger.info { "Converted #{file} in #{t.readable_duration}" }
        end
      end
    end
  end
end
