module Graphene
  module DSL
    class Schema
      def self.mutation
        nil
      end

      macro query(object)
        def self.query
          {{object}}
        end
      end

      macro mutation(object)
        def self.mutation
          {{object}}
        end
      end

      def self.compile(context = nil) : Graphene::Schema
        Graphene::Schema.new(
          query: self.query.compile(context),
          mutation: self.mutation.try(&.compile(context))
        )
      end

      def self.execute(query_string, context = nil, variables = {} of ::String => JSON::Any, operation_name = nil)
        runtime = Graphene::Execution::Runtime.new(
          compile(context),
          Graphene::Query.new(query_string, context, variables, operation_name)
        )

        runtime.execute
      end
    end
  end
end