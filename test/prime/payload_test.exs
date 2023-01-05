defmodule Protohackers.Prime.PayloadTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.Prime.Payload

  property "should be a valid changeset with valid data" do
    check all number <- integer(1..10000) do
      changeset = Payload.changeset(%Payload{}, %{"method" => "isPrime", "number" => number})

      assert changeset.valid? == true
    end
  end

  property "should be an invalid changeset with invalid method value" do
    check all number <- integer(1..10000), string <- string(:ascii) do
      changeset = Payload.changeset(%Payload{}, %{"method" => string, "number" => number})

      assert changeset.valid? == false
    end
  end
end
