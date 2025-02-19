# frozen_string_literal: true

module CountLine
  def lines_exceed?(lines)
    each_line do
      break if lineno >= lines
    end

    (!eof?).tap { rewind }
  end
end
