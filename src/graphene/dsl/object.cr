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
          {% verbatim do %}
            def self.compile_fields(context) : Array(Graphene::Schema::Field)
              fields = [] of Graphene::Schema::Field

              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

              {% for method in methods %}
                arguments = [] of Graphene::Schema::Argument

                {% for argument in method.annotations(Argument) %}
                  arguments << Graphene::Schema::Argument.new(
                    name: {{argument["name"]}},
                    type: {{argument["type"]}}.compile(context)
                  )
                {% end %}

                fields << Graphene::Schema::Field.new(
                  name: {{ method.annotation(Field)["name"] }},
                  type: {{method.annotation(Field)["name"].id}}_type(context),
                  arguments: arguments
                )
              {% end %}

              fields
            end

            def self.compile(context) : Graphene::Types::Object
              Graphene::Types::Object.new(
                name: self.graphql_name,
                resolver: Graphene::DSL::ObjectResolver.new(self),
                implements: self.interfaces.map(&.compile(context)),
                fields: self.compile_fields(context)
              )
            end

            def self.resolve(object, context, field_name, argument_values)
              {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

              klass = new

              case field_name
              {% for method in methods %}
              when {{ method.annotation(Field)["name"] }}
                {{method.name}}(object, field_name, argument_values)
              {% end %}
              else
                interfaces.each do |interface|
                  if interface.resolves_field?(field_name)
                    return interface.resolve(object, context, field_name, argument_values)
                  end
                end
              end
            end
          {% end %}
        end
      end
    end
  end
end