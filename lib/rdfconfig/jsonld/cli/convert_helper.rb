# frozen_string_literal: true

require 'tmpdir'

module Rdfconfig
  module Jsonld
    module CLI
      module ConvertHelper
        def run_in_batch(file, **options)
          options = options.transform_keys(&:to_sym)

          if (ext = File.extname(file)) == '.gz'
            ext = File.extname(File.basename(file, '.gz'))
          end

          raise Error, "Failed to obtain extension: #{file}" if ext.empty?

          file = File.realpath(file)
          options[:config_dir] = File.realpath(options[:config_dir])

          Dir.mktmpdir do |dir|
            output = inside(dir) do
              files = InputReader.from_path(file).split(header_lines: options[:header_lines],
                                                        lines: options[:lines],
                                                        suffix: ext)

              runner = Runner.new(Strategy::DefaultExecuter.new(*files, **options, output_dir: dir))
              runner.run(**options)
            end

            break unless output

            FileUtils.mkdir_p(options[:output_dir])
            FileUtils.mv(File.join(dir, output), options[:output_dir])
          end
        end

        def convert_file(file, **options)
          options = options.transform_keys(&:to_sym)

          inside options[:output_dir] do
            Jsonld.rdf_config_convert(file, **options) do |conv|
              stdout = $stdout.dup
              stderr = $stderr.dup

              File.open("#{options[:file_prefix]}#{Jsonld.output_rdf_extension(options[:format])}", 'w') do |f|
                $stdout.reopen(f)
                $stderr.reopen(File::NULL)
                conv.generate
              end

              $stdout.reopen(stdout)
              $stderr.reopen(stderr)
            end
          end
        end
      end
    end
  end
end
