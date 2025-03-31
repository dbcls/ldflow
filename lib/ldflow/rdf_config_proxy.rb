# frozen_string_literal: true

module Ldflow
  class RdfConfigProxy
    def initialize(path)
      $LOAD_PATH.unshift(RDFCONFIG_LIB) unless $LOAD_PATH.include?(RDFCONFIG_LIB)
      require 'rdf-config'
      @path = path
    end

    def config
      @config ||= RDFConfig::Config.new(@path)
    end

    def model
      @model ||= RDFConfig::Model.instance(config)
    end

    # @see https://github.com/dbcls/rdf-config
    def convert(file, **options, &)
      convert_opts = {
        convert_source: file,
        format: options[:format]
      }

      Ldflow.logger.debug('RDFConfig::Convert') { "config = #{@path}" }
      Ldflow.logger.debug('RDFConfig::Convert') { "options = #{convert_opts.inspect}" }

      convert = RDFConfig::Convert.new(config, **convert_opts)

      yield convert
    end
  end
end
