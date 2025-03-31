# frozen_string_literal: true

require_relative 'ldflow/version'

require 'benchmark'

module Ldflow
  GEM_ROOT = File.expand_path('..', File.dirname(__FILE__))
  HOME_DIRECTORY_NAME = '.ldflow'
  RDFCONFIG_LIB = File.join(GEM_ROOT, 'vendor', 'rdf-config', 'lib')

  class Error < StandardError; end

  def self.home
    Pathname.new(Dir.home).join(HOME_DIRECTORY_NAME)
  end

  # convert benchmark time to readable string
  require 'ldflow/util/readable_duration'
  Float.include(ReadableDuration)

  def self.logger
    # default logger is null logger
    @logger ||= Logger.new(File::NULL)
  end

  attr_writer :logger

  module_function :logger=

  require 'ldflow/strategy/default_executor'
  require 'ldflow/reader'
  require 'ldflow/logger'
  require 'ldflow/middleware'
  require 'ldflow/models'
  require 'ldflow/rdf_config_proxy'
  require 'ldflow/runner'
  require 'ldflow/writer'
end
