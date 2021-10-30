require "./compilable"

module Graphene
  module DSL
    class String
      include Compilable

      def self.compile(context)
        Graphene::Types::String.new
      end
    end
  end
end