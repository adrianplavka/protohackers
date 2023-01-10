defmodule Protohackers.Database.RequestTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.Database.Request

  property "should decode version payload" do
    check all payload <- constant("version") do
      assert {:ok, :version} = Request.decode_payload(payload)
    end
  end

  property "should not handle an insert payload on version key" do
    check all key <- constant("version"),
              delimiter <- constant("="),
              value <- string(Enum.concat([?a..?z, ?A..?Z, ?0..?9, [?=]])) do
      assert :error = Request.decode_payload(key <> delimiter <> value)
    end
  end

  property "should decode insert payload" do
    check all key <- filter(string(:alphanumeric), fn x -> x != "version" end),
              delimiter <- constant("="),
              value <- string(Enum.concat([?a..?z, ?A..?Z, ?0..?9, [?=]])) do
      assert {:ok, :insert, ^key, ^value} = Request.decode_payload(key <> delimiter <> value)
    end
  end

  property "should decode retrieve payload" do
    check all key <- filter(string(:alphanumeric), fn x -> x != "version" end) do
      assert {:ok, :retrieve, ^key} = Request.decode_payload(key)
    end
  end

  property "should handle an invalid payload" do
    check all payload <- filter(term(), fn x -> not is_binary(x) end) do
      assert :error = Request.decode_payload(payload)
    end
  end
end
