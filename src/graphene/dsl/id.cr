module Graphene
  module DSL
    class Id
      def self.compile(context)
        Graphene::Types::Id.new
      end
    end
  end
end