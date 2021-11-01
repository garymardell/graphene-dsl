require "./named"
require "./fields"

module Graphene
  module DSL
    class Interface
      include Named
      include Fields

      def self.resolve_type(object, context)
      end

      def self.resolve(object, context, field_name, argument_values)
        {% begin %}
        {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}

        klass = new

        case field_name
        {% for method in methods %}
        when {{ method.annotation(Field)["name"] }}
          {{method.name}}(object, field_name, argument_values)
        {% end %}
        end
        {% end %}
      end

      def self.resolves_field?(field_name)
        {% begin %}
        field_names = [] of ::String

        {% methods = @type.class.methods.select { |m| m.annotation(Field) } %}
        {% for method in methods %}
          field_names << {{ method.annotation(Field)["name"] }}
        {% end %}

        field_names.includes?(field_name)
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
        Graphene::Types::Interface.new(
          name: self.graphql_name,
          type_resolver: Graphene::DSL::InterfaceResolver.new(self),
          fields: self.compile_fields(context)
        )
      end
    end
  end
end