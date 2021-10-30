require "./compilable"

module Graphene
  module DSL
    class Id
      include Compilable

      def self.compile(context)
        Graphene::Types::Id.new
      end
    end
  end
end