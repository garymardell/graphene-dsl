require "./field"
require "./enum_value"
require "./input_value"

module Graphql
  module Introspection
    TypeKind = Graphql::Type::Enum.new(
      values: [
        Graphql::Type::EnumValue.new(name: "SCALAR"),
        Graphql::Type::EnumValue.new(name: "OBJECT"),
        Graphql::Type::EnumValue.new(name: "INTERFACE"),
        Graphql::Type::EnumValue.new(name: "UNION"),
        Graphql::Type::EnumValue.new(name: "ENUM"),
        Graphql::Type::EnumValue.new(name: "INPUT_OBJECT"),
        Graphql::Type::EnumValue.new(name: "LIST"),
        Graphql::Type::EnumValue.new(name: "NON_NULL")
      ]
    )

    Type = Graphql::Type::Object.new(
      typename: "__Type",
      resolver: TypeResolver.new,
      fields: [
        Graphql::Schema::Field.new(
          name: "kind",
          type: Graphql::Type::NonNull.new(of_type: TypeKind)
        ),
        Graphql::Schema::Field.new(
          name: "name",
          type: Graphql::Type::String.new
        ),
        Graphql::Schema::Field.new(
          name: "description",
          type: Graphql::Type::String.new
        ),
        Graphql::Schema::Field.new(
          name: "fields",
          arguments: [
            Graphql::Schema::Argument.new(
              name: "includeDeprecated",
              type: Graphql::Type::Boolean.new,
              default_value: false
            )
          ],
          type: Graphql::Type::List.new(
            of_type: Graphql::Type::NonNull.new(
              of_type: Graphql::Type::LateBound.new("__Field") # Introspection::Field
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "interfaces",
          type: Graphql::Type::List.new(
            of_type: Graphql::Type::NonNull.new(
              of_type: Graphql::Type::LateBound.new("__Type")  # Introspection::Type
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "possibleTypes",
          type: Graphql::Type::List.new(
            of_type: Graphql::Type::NonNull.new(
              of_type: Graphql::Type::LateBound.new("__Type")
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "enumValues",
          type: Graphql::Type::List.new(
            of_type: Graphql::Type::NonNull.new(
              of_type: Introspection::EnumValue
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "inputFields",
          type: Graphql::Type::List.new(
            of_type: Graphql::Type::NonNull.new(
              of_type: Graphql::Type::LateBound.new("__InputValue") # Introspection::InputValue
            )
          )
        ),
        Graphql::Schema::Field.new(
          name: "ofType",
          type: Graphql::Type::LateBound.new("__Type")
        )
      ]
    )

    IntrospectionSystem.register_type("__Type", Type)
  end
end