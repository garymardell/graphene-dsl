module Graphene
  module DSL
    module Fields
      macro field(name, mutation)
        @[Field(name: "{{name.id}}", type: {{mutation}}, null: false)]
        def self.{{name.id}}_resolve(object, field_name, argument_values)
          klass = new
          klass.{{name.id}}(object, argument_values)
        end

        def {{name.id}}(object, argument_values)
          klass = {{mutation}}.new
          klass.resolve(argument_values)
        end

        def self.{{name.id}}_arguments(context)
          {{mutation}}.arguments(context)
        end

        def self.{{name.id}}_type(context)
          field_type = {{mutation}}.compile(context)

          Graphene::Types::NonNull.new(of_type: field_type)
        end
      end

      macro field(name, type, null, &blk)
        @[Field(name: "{{name.id}}", type: {{type}}, null: null)]
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

        # TODO: Refactor to get arguments for this field to avoid concat below
        def self.{{name.id}}_arguments(context)
          [] of Graphene::Schema::Argument
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
    end
  end
end