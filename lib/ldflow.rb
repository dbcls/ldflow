# frozen_string_literal: true

require_relative 'ldflow/version'

require 'benchmark'

module Ldflow
  GEM_ROOT = File.expand_path('../../', File.dirname(__FILE__))
  RDFCONFIG_LIB = File.join(GEM_ROOT, 'vendor', 'rdf-config', 'lib')

  class Error < StandardError; end

  require 'ldflow/strategy/default_executor'
  require 'ldflow/util/readable_duration'
  require 'ldflow/reader'
  require 'ldflow/logger'
  require 'ldflow/runner'
  require 'ldflow/writer'

  # convert benchmark time to readable string
  Float.include(ReadableDuration)

  def self.logger
    # default logger is null logger
    @logger ||= Logger.new(File::NULL)
  end

  attr_writer :logger

  module_function :logger=

  # @see https://github.com/dbcls/rdf-config
  def self.rdf_config_convert(file, **options, &)
    $LOAD_PATH.unshift(RDFCONFIG_LIB) unless $LOAD_PATH.include?(RDFCONFIG_LIB)

    require 'rdf-config'

    config = RDFConfig::Config.new(options[:config_dir])

    Ldflow.logger.info { "Converting #{file} to #{options[:format]}" }
    Ldflow.logger.debug { "options: #{options}" }
    convert = RDFConfig::Convert.new(config, convert_source: file, format: options[:format])

    yield convert
  end

  def self.output_rdf_extension(format)
    case format
    when 'jsonl'
      '.jsonl'
    when 'jsonld', 'json-ld', 'json_ld'
      '.jsonld'
    else
      '.ttl'
    end
  end
end
