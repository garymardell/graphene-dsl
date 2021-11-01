module Graphene
  module DSL
    class String
      def self.compile(context)
        Graphene::Types::String.new
      end
    end
  end
end