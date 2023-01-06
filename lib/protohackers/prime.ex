defmodule Protohackers.Prime do
  @moduledoc """
  Module for defining logic around prime numbers.
  """

  @spec prime?(number) :: boolean
  def prime?(number)

  def prime?(number) when is_float(number), do: false
  def prime?(number) when number <= 1, do: false
  def prime?(number) when number in [2, 3], do: true

  def prime?(number) do
    floored_sqrt =
      number
      |> :math.sqrt()
      |> Float.floor()
      |> round()

    not Enum.any?(2..floored_sqrt, &(rem(number, &1) == 0))
  end
end
