# frozen_string_literal: true

require 'zlib'

module Rdfconfig
  module Jsonld
    class Writer
      class << self
        def from_path(path, &)
          if path == '-'
            yield $stdout
            return
          end

          case File.extname(path)
          when '.gz'
            Zlib::GzipWriter.open(path, &)
          else
            File.open(path, 'w', &)
          end
        end
      end
    end
  end
end
