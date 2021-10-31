module Graphene
  module DSL
    module Fields
      macro argument(name, type, required)
        @[Argument(name: "{{name.id}}", type: {{type}}, required: {{required}})]
      end

      macro field(name, mutation)
        @[Field(name: "{{name.id}}", type: mutation, null: false)]
        def self.{{name.id}}_resolve(object, field_name, argument_values)
          klass = new
          klass.{{name.id}}(object, argument_values)
        end

        def {{name.id}}(object, argument_values)
          klass = {{mutation}}.new
          klass.resolve(argument_values)
        end

        def self.{{name.id}}_type(context)
          field_type = {{mutation}}.compile(context)

          Graphene::Types::NonNull.new(of_type: field_type)
        end
      end

      macro field(name, type, null, &blk)
        @[Field(name: "{{name.id}}", type: type, null: null)]
        {{blk && blk.body}}
        def self.{{name.id}}_resolve(object, field_name, argument_values)
          klass = new
          klass.{{name.id}}(object, argument_values)
        end

        def {{name.id}}(object, argument_values)
          case object
          when Hash
            object["{{name.id}}"]?
          else
            if object.responds_to?(:{{name.id}})
              object.{{name.id}}
            end
          end
        end

        def self.{{name.id}}_type(context)
          {% if type.is_a?(ArrayLiteral) %}
            field_type = Graphene::Types::List.new(of_type: {{type}}.first.compile(context))
          {% else %}
            field_type = {{type}}.compile(context)
          {% end %}

          unless {{null}}
            Graphene::Types::NonNull.new(of_type: field_type)
          else
            field_type
          end
        end
      end

      macro define_resolve_fields
        def self.resolve(object, context, field_name, argument_values)
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
        end
      end

      macro define_compile_fields
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
      end
    end
  end
end