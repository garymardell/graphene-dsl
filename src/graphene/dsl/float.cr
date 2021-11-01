module Graphene
  module DSL
    class Float
      def self.compile(context)
        Graphene::Types::Float.new
      end
    end
  end
end