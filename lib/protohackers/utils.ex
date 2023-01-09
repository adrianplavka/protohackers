defmodule Protohackers.Utils do
  @moduledoc """
  Module that contains utility functions.
  """

  @spec with_newline(binary) :: binary
  def with_newline(string),
    do: string <> "\n"

  @spec without_newline(binary) :: binary
  def without_newline(data),
    do: data |> String.replace("\n", "") |> String.replace("\r", "")

  @spec alphanumeric?(binary) :: boolean
  def alphanumeric?(string),
    do: Regex.match?(~r/^[[:alnum:]]*$/, string)
end
