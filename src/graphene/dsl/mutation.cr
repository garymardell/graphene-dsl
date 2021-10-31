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

      abstract def resolve(argument_values)

      macro inherited
        macro finished
          {% verbatim do %}
            define_compile_fields
            # define_resolve_fields

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