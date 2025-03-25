# frozen_string_literal: true

require 'logger'

module Ldflow
  class Logger < ::Logger
    DEFAULT_OPTIONS = {
      formatter: ::Logger::Formatter.new,
      level: ::Logger::INFO,
      progname: 'ldflow'
    }.freeze
    private_constant :DEFAULT_OPTIONS

    def initialize(logdev, **options)
      super(logdev, **DEFAULT_OPTIONS.merge(options))
    end
  end
end
