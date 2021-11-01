module Graphene
  module DSL
    class Int
      def self.compile(context)
        Graphene::Types::Int.new
      end
    end
  end
end