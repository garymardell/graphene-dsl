require "./object"

module Graphene
  module DSL
    class DelegateResolver < Graphene::Schema::Resolver
      def initialize(klass : Graphene::DSL::Object.class | Graphene::DSL::Mutation.class)
        @klass = klass
      end

      def resolve(object, context, field_name, argument_values)
        @klass.resolve(object, context, field_name, argument_values)
      end
    end
  end
end