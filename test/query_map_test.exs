defmodule Protohackers.QueryMapTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Protohackers.QueryMap

  test "should insert & query data successfully according to the example" do
    query_map =
      QueryMap.new()
      |> QueryMap.insert(12345, 101)
      |> QueryMap.insert(12346, 102)
      |> QueryMap.insert(12347, 100)
      |> QueryMap.insert(40960, 5)
      |> QueryMap.query(12288, 16384)

    assert query_map.data == %{12345 => 101, 12346 => 102, 12347 => 100}
  end

  property "should always return empty list on query when minimum key is greater than maximum key" do
    check all timestamps <- list_of(integer(0..50000), length: 100),
              prices <- list_of(integer(0..50000), length: 100),
              min_key <- integer(50001..100_000),
              max_key <- integer(0..50000) do
      query_map =
        Enum.zip(timestamps, prices)
        |> Enum.reduce(QueryMap.new(), fn {timestamp, price}, acc ->
          QueryMap.insert(acc, timestamp, price)
        end)

      assert 0 == query_map |> QueryMap.query(min_key, max_key) |> QueryMap.length()
    end
  end

  property "should implement enumerable protocol" do
    check all timestamps <- list_of(integer(0..50000), length: 100),
              prices <- list_of(integer(0..50000), length: 100) do
      timestamps_and_prices =
        Enum.zip(timestamps, prices)
        |> Enum.uniq_by(fn {timestamp, _price} -> timestamp end)

      query_map =
        timestamps_and_prices
        |> Enum.reduce(QueryMap.new(), fn {timestamp, price}, acc ->
          QueryMap.insert(acc, timestamp, price)
        end)

      assert timestamps_and_prices |> Enum.all?(fn value -> Enum.member?(query_map, value) end)

      total_price =
        timestamps_and_prices
        |> Enum.map(fn {_, price} -> price end)
        |> Enum.reduce(0, fn price, acc -> price + acc end)

      query_map_total_price = Enum.reduce(query_map, 0, fn {_, price}, acc -> price + acc end)
      assert total_price == query_map_total_price

      mean_price = total_price / length(timestamps_and_prices)
      query_map_mean = query_map_total_price / QueryMap.length(query_map)
      assert mean_price == query_map_mean
    end
  end
end
