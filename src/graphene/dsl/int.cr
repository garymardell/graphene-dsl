require "./compilable"

module Graphene
  module DSL
    class Int
      include Compilable

      def self.compile(context)
        Graphene::Types::Int.new
      end
    end
  end
end