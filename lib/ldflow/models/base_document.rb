# frozen_string_literal: true

module Ldflow
  module Models
    class BaseDocument
      include Elasticsearch::Model

      index_name do
        raise Error, 'Index name not configured'
      end

      settings index: {
        number_of_shards: 1,
        number_of_replicas: 0
      }

      class << self
        module ConnectionProxy
          def __elasticsearch__
            Models.establish_connection
            super
          end
        end

        prepend ConnectionProxy

        def client
          __elasticsearch__.client
        end

        def create_index
          raise Error, "Index already exists: #{index_name}" if __elasticsearch__.index_exists?
          raise Error, 'Empty mapping' if mappings.to_hash[:properties].empty?

          __elasticsearch__.create_index!
        end

        def delete_index
          __elasticsearch__.delete_index!
        end
      end
    end
  end
end
