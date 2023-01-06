defmodule Protohackers.Prime.PayloadTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.Prime.Payload

  import Ecto.Changeset, only: [apply_changes: 1]

  property "should be a valid changeset with valid data" do
    check all number <- integer(1..10000) do
      changeset = create_changeset("isPrime", number)

      assert changeset.valid? == true
    end
  end

  property "should be a valid changeset with valid float number data" do
    check all number <- float(min: 0, max: 10000) do
      changeset = create_changeset("isPrime", number)

      assert changeset.valid? == true

      payload = apply_changes(changeset)
      assert is_integer(payload.number) == true
    end
  end

  property "should be an invalid changeset with invalid method value" do
    check all string <- string(:ascii), number <- integer(1..10000) do
      changeset = create_changeset(string, number)

      assert changeset.valid? == false
    end
  end

  defp create_changeset(method, number) do
    Payload.changeset(%Payload{}, %{"method" => method, "number" => number})
  end
end
