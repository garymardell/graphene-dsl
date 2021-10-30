require "./compilable"
require "./named"
require "./fields"

module Graphene
  module DSL
    class Union
      include Compilable
      include Named

      def self.resolve_type(object, context)
      end

      def self.resolve(object, context, field_name, argument_values)
      end

      macro possible_types(*types)
        def self.possible_types(context)
          possible_types = [] of Graphene::Type

          {% for type in types %}
            possible_types << {{type}}.compile(context)
          {% end %}

          possible_types
        end
      end

      def self.possible_types(context)
        [] of Graphene::Type
      end

      macro inherited
        macro finished
          {% verbatim do %}
            def self.compile(context)
              Graphene::Types::Union.new(
                name: self.graphql_name,
                type_resolver: Graphene::DSL::UnionResolver.new(self),
                possible_types: self.possible_types(context)
              )
            end
          {% end %}
        end
      end
    end
  end
end