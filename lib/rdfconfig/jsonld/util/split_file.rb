# frozen_string_literal: true

require 'rdfconfig/jsonld/writer'

module SplitFile
  def split(**options)
    options[:header_lines] ||= 0

    raise ArgumentError, '`lines` must be greater than or equal to 0' unless options[:lines] >= 0
    raise ArgumentError, '`lines` must be positive integer' unless options[:lines].positive?

    headers = Array.new(options[:header_lines]).map { readline }.join

    files = []
    i = 0
    loop do
      Rdfconfig::Jsonld::Writer.from_path((path = "#{options[:prefix]}#{i}#{options[:suffix]}")) do |f|
        f << headers

        each_line do |line|
          f << line
          break if ((lineno - options[:header_lines]) % options[:lines]).zero?
        end
      end

      files << path

      break if eof?

      i += 1
    end

    files
  end
end
