# frozen_string_literal: true

require 'tmpdir'

module Rdfconfig
  module Jsonld
    module CLI
      module ConvertHelper
        def run_in_batch(file, **options)
          options = options.transform_keys(&:to_sym)

          if (ext = File.extname(file)) == '.gz'
            ext = File.extname(File.basename(file, ext))
          end

          raise Error, "Failed to obtain extension: #{file}" if ext.empty?

          file = File.realpath(file)
          options[:config_dir] = File.realpath(options[:config_dir])

          t = Benchmark.realtime do
            Dir.mktmpdir do |dir|
              Jsonld.logger.debug { "Created temporary directory: #{dir}" }

              output = inside(dir) do
                Jsonld.logger.info { "Splitting the input file into #{options[:lines]} lines per file" }

                files = InputReader.from_path(file).split(header_lines: options[:header_lines],
                                                          lines: options[:lines],
                                                          prefix: 'chunk_',
                                                          suffix: ext)

                Jsonld.logger.info { "Split into #{files.size} files" }

                Runner.new(Strategy::DefaultExecutor.new(*files), **options, output_dir: dir).run
              end

              break unless output

              inside options[:output_dir] do
                FileUtils.mv(File.join(dir, output), '.')
                Jsonld.logger.debug { "Moved output to #{File.join(options[:output_dir], output)}" }
              end
            end
          end

          Jsonld.logger.info { "Converted #{file} in #{t.readable_duration}" }
        end

        def convert_file(file, **options)
          options = options.transform_keys(&:to_sym)

          Jsonld.rdf_config_convert(file, **options) do |conv|
            stdout = $stdout.dup
            stderr = $stderr.dup

            t = Benchmark.realtime do
              inside options[:output_dir] do
                File.open("#{options[:file_prefix]}#{Jsonld.output_rdf_extension(options[:format])}", 'w') do |f|
                  $stdout.reopen(f)
                  $stderr.reopen(File::NULL)
                  conv.generate
                end
              end
            end

            $stdout.reopen(stdout)
            $stderr.reopen(stderr)

            Jsonld.logger.info { "Converted #{file} in #{t.readable_duration}" }
          end
        end
      end
    end
  end
end
