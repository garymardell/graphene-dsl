require "./named"

module Graphene
  module DSL
    class Enum
      include Named

      macro value(name, value)
        @[EnumValue(name: "{{name.id}}")]
        def self.{{name.id.downcase}}_value
          Graphene::Types::EnumValue.new(name: "{{name.id}}", value: "{{value.id}}")
        end
      end

      macro inherited
        macro finished
          {% verbatim do %}
            def self.compile(context)
              values = [] of Graphene::Types::EnumValue

              {% methods = @type.class.methods.select { |m| m.annotation(EnumValue) } %}
              {% for method in methods %}
                values << {{ method.annotation(EnumValue)["name"].downcase.id }}_value
              {% end %}

              Graphene::Types::Enum.new(
                name: graphql_name,
                values: values
              )
            end
          {% end %}
        end
      end
    end
  end
end