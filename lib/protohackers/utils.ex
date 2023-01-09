defmodule Protohackers.Utils do
  @moduledoc """
  Module that contains utility functions.
  """

  @spec alphanumeric?(binary) :: boolean
  def alphanumeric?(string),
    do: Regex.match?(~r/^[[:alnum:]]*$/, string)
end
