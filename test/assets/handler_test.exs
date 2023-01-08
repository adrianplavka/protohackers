defmodule Protohackers.Assets.HandlerTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.Assets.Handler

  property "should decode valid payload" do
    check all method <- one_of([constant({:insert, "I"}), constant({:query, "Q"})]),
              a <- integer(-20000..20000),
              b <- integer(-20000..20000) do
      {method_atom, method_op} = method

      assert {:ok, ^method_atom, ^a, ^b} =
               Handler.decode_payload(
                 <<method_op::binary, a::integer-signed-size(32), b::integer-signed-size(32)>>
               )
    end
  end

  property "should fail decoding invalid payload" do
    check all method <- filter(string(:ascii, length: 1), fn x -> x not in ["I", "Q"] end),
              a <- integer(1..20000),
              b <- integer(1..20000),
              a_size <- filter(integer(1..64), fn x -> x != 32 end),
              b_size <- filter(integer(1..64), fn x -> x != 32 end) do
      assert :error =
               Handler.decode_payload(
                 <<method::binary, a::integer-signed-size(a_size),
                   b::integer-signed-size(b_size)>>
               )
    end
  end
end
