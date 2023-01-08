defmodule Protohackers.QueryMap do
  @moduledoc """
  Data structure that allows to insert & query map.

  Each query map contains keys with a corresponding value. This structure a
  llows to query data based on minimum & maximum key, which will then output a
  new query map, satisfying those keys in range.

  Implements `Enumerable` protocol.
  """

  @type t :: %__MODULE__{}

  defstruct data: %{}

  @spec new :: %Protohackers.QueryMap{data: %{}}
  def new do
    %__MODULE__{}
  end

  @spec insert(query_map :: t, key :: integer(), value :: integer()) :: t
  def insert(query_map, key, value) do
    %__MODULE__{query_map | data: Map.put_new(query_map.data, key, value)}
  end

  @spec query(query_map :: t, min_key :: integer(), max_key :: integer()) :: t
  def query(query_map, min_key, max_key)

  def query(query_map, min_key, max_key) when min_key > max_key do
    %__MODULE__{query_map | data: %{}}
  end

  def query(query_map, min_key, max_key) do
    %__MODULE__{
      query_map
      | data:
          Map.filter(query_map.data, fn {key, _} ->
            min_key <= key and key <= max_key
          end)
    }
  end

  @spec length(query_map :: t) :: non_neg_integer()
  def length(query_map), do: map_size(query_map.data)
end

defimpl Enumerable, for: Protohackers.QueryMap do
  def count(query_map) do
    Enumerable.Map.count(query_map.data)
  end

  def member?(query_map, value) do
    Enumerable.Map.member?(query_map.data, value)
  end

  def slice(query_map) do
    Enumerable.Map.slice(query_map.data)
  end

  def reduce(query_map, acc, fun) do
    Enumerable.Map.reduce(query_map.data, acc, fun)
  end
end
