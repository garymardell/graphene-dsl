require "./named"
require "./fields"
require "./interface"

module Graphene
  module DSL
    abstract class Mutation
      include Named
      include Fields

      macro argument(name, type, required)
        @[Argument(name: "{{name.id}}", type: {{type}}, required: {{required}})]
        def self.{{name.id}}_argument
        end
      end

      abstract def resolve(argument_values)

      def self.resolve(object, context, field_name, argument_values)
        {% begin %}
          {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

          klass = new

          case field_name
          {% for method in methods %}
          when {{ method.annotation(Field)["name"] }}
            {{method.name}}(object, field_name, argument_values)
          {% end %}
          else
            {% if @type.class.has_method?(:interfaces) %}
              interfaces.each do |interface|
                if interface.resolves_field?(field_name)
                  return interface.resolve(object, context, field_name, argument_values)
                end
              end
            {% end %}
          end
        {% end %}
      end

      def self.arguments(context)
        {% begin %}
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
        {% end %}
      end

      def self.compile_fields(context) : Array(Graphene::Schema::Field)
        {% begin %}
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

          arguments.concat self.{{method.annotation(Field)["name"].id}}_arguments(context)

          fields << Graphene::Schema::Field.new(
            name: {{ method.annotation(Field)["name"] }},
            type: {{method.annotation(Field)["name"].id}}_type(context),
            arguments: arguments
          )
        {% end %}

        fields
        {% end %}
      end

      def self.compile(context)
        Graphene::Types::Object.new(
          name: self.graphql_name,
          resolver: Graphene::DSL::DelegateResolver.new(self),
          fields: self.compile_fields(context)
        )
      end
    end
  end
end