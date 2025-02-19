# frozen_string_literal: true

require 'zlib'

module Rdfconfig
  module Jsonld
    class Runner
      def initialize(executer)
        @executer = executer
      end

      # @return [String] path to merged output
      def run(**options)
        outputs = @executer.execute

        output = "#{options[:file_prefix]}#{Jsonld.output_rdf_extension(options[:format])}.gz"
        Zlib::GzipWriter.open(output) do |gz|
          outputs.each do |path|
            gz << File.read(path)
          end
        end

        output
      end
    end
  end
end
