require "../spec_helper"

describe Graphene::DSL do
  it "executes" do
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
end