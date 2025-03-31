# frozen_string_literal: true

require 'elasticsearch'
require 'elasticsearch/model'

module Ldflow
  module Models
    require 'ldflow/models/base_document'

    def self.establish_connection
      return @client if @client

      env = Middleware.env

      options = {
        host: "localhost:#{env.fetch('ES_PORT')}",
        user: 'elastic',
        password: env.fetch('ES_PASSWORD'),
        log: true,
        trace: true,
        logger: Ldflow.logger,
        tracer: Ldflow.logger
      }

      @client = ::Elasticsearch::Model.client = ::Elasticsearch::Client.new(**options)
    end

    def self.create_model(name, config, **options, &)
      klass = Class.new(BaseDocument) do
        index_name name

        mappings do
          # TODO: define mappings with config
        end
      end

      yield klass if block_given?

      klass
    end
  end
end
