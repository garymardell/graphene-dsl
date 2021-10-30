require "./compilable"

module Graphene
  module DSL
    class Boolean
      include Compilable

      def self.compile(context)
        Graphene::Types::Boolean.new
      end
    end
  end
end