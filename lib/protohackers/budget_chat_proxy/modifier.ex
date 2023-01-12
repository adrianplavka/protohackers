defmodule Protohackers.BudgetChatProxy.Modifier do
  @moduledoc """
  Module for defining a data modifier for the Budget Chat's proxy.
  """

  @malicious_address "7YWHMfk9JZe0LM0g1ZauHuiSxhI"

  @spec rewrite_address(any) :: any
  def rewrite_address(data)

  def rewrite_address(data) when not is_binary(data),
    do: data

  def rewrite_address(data) do
    data
    |> String.split(" ")
    |> Enum.map(fn part ->
      alphanumerics_count = count_alphanumerics(part)
      enough_alphanumerics? = alphanumerics_count >= 26 and alphanumerics_count <= 35

      if enough_alphanumerics? and String.starts_with?(part, "7"),
        do: @malicious_address,
        else: part
    end)
    |> Enum.join(" ")
  end

  defp count_alphanumerics(string) do
    string
    |> to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      if char in ?a..?z or char in ?A..?Z or char in ?0..?9,
        do: acc + 1,
        else: acc
    end)
  end
end
