module Graphene
  module DSL
    class InterfaceResolver < Graphene::Schema::TypeResolver
      def initialize(@interface : Graphene::DSL::Interface.class)
      end

      def resolve_type(object, context)
        type = @interface.resolve_type(object, context)

        if type
          type.compile(context)
        else
          raise "type not found"
        end
      end
    end
  end
end