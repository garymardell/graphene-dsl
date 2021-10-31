require "../spec_helper"

describe Graphene::DSL do
  it "executes a query" do
    query_string = <<-QUERY
      query {
        charges {
          id
        }
      }
    QUERY

    result = DummySchema.execute(query_string)["data"]

    result.should eq({ "charges" => [{ "id" => "1" }, { "id" => "2" }, { "id" => "3" }] })
  end

  it "executes a mutation" do
    query_string = <<-QUERY
      mutation CreateCharge($reference : String!) {
        createCharge(reference: $reference) {
          charge {
            id
            reference
          }
        }
      }
    QUERY

    variables = JSON.parse <<-STRING
      {
        "reference": "testing"
      }
    STRING

    result = DummySchema.execute(
      query_string,
      variables: variables.as_h
    )["data"]


    result.should eq({ "createCharge" => { "charge" => { "id" => "1", "reference" => "testing" } } })
  end
end