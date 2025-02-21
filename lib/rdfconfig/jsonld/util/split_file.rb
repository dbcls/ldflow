# frozen_string_literal: true

module SplitFile
  def split(**options)
    raise ArgumentError, '`header_lines` must be positive integer' unless options[:header_lines].positive?
    raise ArgumentError, '`lines` must be positive integer' unless options[:lines].positive?

    headers = Array.new(options[:header_lines]).map { readline }.join

    files = []
    i = 0
    loop do
      File.open((path = "#{options[:prefix]}#{i}#{options[:suffix]}"), 'w') do |f|
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
