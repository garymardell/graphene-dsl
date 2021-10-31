require "./compilable"
require "./named"
require "./fields"
require "./interface"

module Graphene
  module DSL
    abstract class Object
      include Compilable
      include Named
      include Fields

      macro argument(name, type, required)
        @[Argument(name: "{{name.id}}", type: {{type}}, required: {{required}})]
      end

      macro implements(*interfaces)
        def self.interfaces
          interfaces = [] of Graphene::DSL::Interface.class

          {% for interface in interfaces %}
            interfaces << {{interface}}
          {% end %}

          interfaces
        end
      end

      def self.interfaces
        [] of Graphene::DSL::Interface.class
      end

      def self.resolve(object, context, field_name, argument_values)
      end

      macro inherited
        macro finished
          define_compile_fields

          {% verbatim do %}
            def self.compile(context) : Graphene::Types::Object
              Graphene::Types::Object.new(
                name: self.graphql_name,
                resolver: Graphene::DSL::DelegateResolver.new(self),
                implements: self.interfaces.map(&.compile(context)),
                fields: self.compile_fields(context)
              )
            end

            define_resolve_fields
          {% end %}
        end
      end
    end
  end
end