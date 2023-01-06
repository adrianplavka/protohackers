defmodule Protohackers.Prime.HandlerTest do
  use ExUnit.Case
  use ExUnitProperties

  import Protohackers.Prime
  import Protohackers.Prime.Handler

  property "should return conforming response for a valid payload" do
    check all number <- integer(1..10000) do
      is_number_prime = prime?(number)
      payload = Jason.encode!(%{"method" => "isPrime", "number" => number})

      assert {:continue, response} = handle_payload(payload)
      assert %{"method" => "isPrime", "prime" => ^is_number_prime} = Jason.decode!(response)
    end
  end

  property "should return malformed response for an invalid payload" do
    check all formedJson? <- boolean(),
              requiredFields? <- boolean(),
              allowedMethod? <- boolean(),
              number? <- boolean(),
              number <- integer(1..10000),
              string <- string(Enum.concat([?a..?z, ?A..?Z])) do
      response =
        cond do
          not formedJson? ->
            handle_payload("{}")

          not requiredFields? ->
            handle_payload(Jason.encode!(%{"number" => number}))

          not allowedMethod? ->
            handle_payload(Jason.encode!(%{"method" => "isNotPrime", "number" => number}))

          not number? ->
            handle_payload(Jason.encode!(%{"method" => "isPrime", "number" => string}))

          true ->
            handle_payload("{}")
        end

      assert {:close, _} = response
    end
  end
end
