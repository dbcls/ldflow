# frozen_string_literal: true

module Ldflow
  module CLI
    class Elasticsearch < Thor
      include Thor::Actions

      class << self
        def exit_on_failure?
          true
        end
      end

      desc 'health', 'Show elasticsearch health'

      def health
        client = Models::BaseDocument.client

        health = {
          cluster: client.cluster.health.body,
          nodes: client.cat.allocation(format: 'json').body,
          indices: client.cat.indices(format: 'json', index: '*,-.*').body,
          shards: client.cat.shards(format: 'json', index: '*,-.*').body
        }

        puts JSON.pretty_generate(health)
      end
    end
  end
end
