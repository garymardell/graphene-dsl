module Graphql
  module Introspection
    class FieldResolver < Graphql::Schema::Resolver
      def resolve(object, field_name, argument_values)
      end
    end
  end
end