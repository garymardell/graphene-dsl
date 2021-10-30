module Graphene
  module DSL
    module Fields
      macro argument(name, type, required)
        @[Argument(name: "{{name.id}}", type: {{type}}, required: {{required}})]
      end

      macro field(name, type, null, &blk)
        @[Field(name: "{{name.id}}")]
        {{blk && blk.body}}
        def self.{{name.id}}_resolve(object, field_name, argument_values)
          klass = new
          klass.{{name.id}}(object, argument_values)
        end

        def {{name.id}}(object, argument_values)
          if object.responds_to?(:{{name.id}})
            object.{{name.id}}
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
    end
  end
end