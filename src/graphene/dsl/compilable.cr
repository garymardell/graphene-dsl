module Graphene
  module DSL
    module Compilable
      macro included
        def self.compile(context)
          raise "compile must be defined"
        end
      end
    end
  end
end