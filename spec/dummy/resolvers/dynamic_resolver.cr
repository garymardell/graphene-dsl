class DynamicResolver < Graphene::Schema::Resolver
  def resolve(object, context, field_name, argument_values)
    field_name
  end
end
