require "./object"

module Graphene
  module DSL
    class ObjectResolver < Graphene::Schema::Resolver
      def initialize(klass : Graphene::DSL::Object.class)
        @klass = klass
      end

      def resolve(object, context, field_name, argument_values)
        @klass.resolve(object, context, field_name, argument_values)
      end
    end
  end
end