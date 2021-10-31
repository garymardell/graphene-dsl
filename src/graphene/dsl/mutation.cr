require "./compilable"
require "./named"
require "./fields"
require "./interface"

module Graphene
  module DSL
    abstract class Mutation
      include Compilable
      include Named
      include Fields

      macro argument(name, type, required)
        @[Argument(name: "{{name.id}}", type: {{type}}, required: {{required}})]
        def self.{{name.id}}_argument
        end
      end

      abstract def resolve(argument_values)

      macro inherited
        macro finished
          {% verbatim do %}
            define_compile_fields

            def self.arguments(context)
              {% methods = @type.class.methods.select { |m| m.annotation(Argument) } %}

              arguments = [] of Graphene::Schema::Argument

              {% for method in methods %}
                {% for argument in method.annotations(Argument) %}
                  arguments << Graphene::Schema::Argument.new(
                    name: {{argument["name"]}},
                    type: {{argument["type"]}}.compile(context)
                  )
                {% end %}
              {% end %}

              arguments
            end

            def self.compile(context)
              Graphene::Types::Object.new(
                name: self.graphql_name,
                resolver: Graphene::DSL::DelegateResolver.new(self),
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