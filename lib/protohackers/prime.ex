defmodule Protohackers.Prime do
  @moduledoc """
  Module for defining logic around prime numbers.
  """

  @spec is_prime(number) :: boolean
  def is_prime(number) do
    Enum.any?(2..trunc(:math.sqrt(number)), fn x ->
      rem(x, 2) == 0
    end)
  end
end
