module Graphene
  module DSL
    module Named
      macro name(name)
        def self.graphql_name
          {{name}}
        end
      end

      macro included
        def self.graphql_name
          self.name
        end
      end
    end
  end
end