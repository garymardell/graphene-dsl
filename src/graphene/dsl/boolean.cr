module Graphene
  module DSL
    class Boolean
      def self.compile(context)
        Graphene::Types::Boolean.new
      end
    end
  end
end