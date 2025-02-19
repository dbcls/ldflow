# frozen_string_literal: true

require_relative 'jsonld/version'

module Rdfconfig
  module Jsonld
    GEM_ROOT = File.expand_path('../../', File.dirname(__FILE__))
    RDFCONFIG_LIB = File.join(GEM_ROOT, 'vendor', 'rdf-config', 'lib')

    class Error < StandardError; end

    require 'rdfconfig/jsonld/strategy/default_executer'
    require 'rdfconfig/jsonld/input_reader'
    require 'rdfconfig/jsonld/runner'

    # @see https://github.com/dbcls/rdf-config
    def self.rdf_config_convert(file, **options, &)
      $LOAD_PATH.unshift(RDFCONFIG_LIB) unless $LOAD_PATH.include?(RDFCONFIG_LIB)

      require 'rdf-config'

      config = RDFConfig::Config.new(options[:config_dir])
      convert = RDFConfig::Convert.new(config, convert_source: file, format: options[:format])

      yield convert
    end

    # @see https://github.com/dbcls/rdf-config/blob/master/lib/rdf-config/convert.rb
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
end
