require "./compilable"

module Graphene
  module DSL
    class Float
      include Compilable

      def self.compile(context)
        Graphene::Types::Float.new
      end
    end
  end
end