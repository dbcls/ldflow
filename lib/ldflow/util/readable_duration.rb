# frozen_string_literal: true

module ReadableDuration
  # @return [String] duration string
  def readable_duration
    d = (self / 60.0 / 60.0 / 24.0).to_i
    h = (self / 60.0 / 60.0).to_i % 24
    m = (self / 60.0).to_i % 60
    s = self % 60

    if d.positive?
      format('%<d>dd %<h>02d:%<m>02d:%<s>02d', { d:, h:, m:, s: })
    elsif h.positive? || m.positive?
      format('%<h>02d:%<m>02d:%<s>02d', { h:, m:, s: })
    else
      format('%<s>.3f s', { s: })
    end
  end
end
