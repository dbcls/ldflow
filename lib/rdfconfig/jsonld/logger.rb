# frozen_string_literal: true

require 'logger'

module Rdfconfig
  module Jsonld
    class Logger < ::Logger
      DEFAULT_OPTIONS = {
        formatter: ::Logger::Formatter.new,
        level: ::Logger::INFO,
        progname: 'rdfconfig-jsonld'
      }.freeze
      private_constant :DEFAULT_OPTIONS

      def initialize(logdev, **options)
        super(logdev, **DEFAULT_OPTIONS.merge(options))
      end
    end
  end
end
