# frozen_string_literal: true

require 'zlib'

module Rdfconfig
  module Jsonld
    require 'rdfconfig/jsonld/util/count_line'
    require 'rdfconfig/jsonld/util/split_file'

    # include utility functions
    File.include(CountLine, SplitFile)
    Zlib::GzipReader.include(CountLine, SplitFile)

    class Reader
      class << self
        def from_path(path, &)
          case File.extname(path)
          when '.tsv', '.csv', '.jsonl'
            File.open(path, &)
          when '.gz'
            Zlib::GzipReader.open(path, &)
          else
            raise Error, "Not supported file format: #{File.extname(path)}"
          end
        end
      end
    end
  end
end
