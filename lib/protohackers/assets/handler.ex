defmodule Protohackers.Assets.Handler do
  use ThousandIsland.Handler

  alias ThousandIsland.Socket
  alias Protohackers.QueryMap

  require Logger

  @impl ThousandIsland.Handler
  def handle_connection(_socket, _state) do
    state = %{buffer: <<>>, query_map: QueryMap.new()}

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    load_data(data, socket, state)
  end

  defp load_data(data, socket, state) do
    case state.buffer <> data do
      <<payload::binary-size(9)>> ->
        handle_payload(payload, socket, state)

      <<payload::binary-size(9), rest::binary>> ->
        case handle_payload(payload, socket, state) do
          {:continue, state} -> load_data(rest, socket, state)
          other -> other
        end

      data ->
        {:continue, %{state | buffer: data}}
    end
  end

  defp handle_payload(payload, socket, state) do
    case decode_payload(payload) do
      {:ok, :insert, timestamp, price} ->
        Logger.info("Inserting payload: timestamp #{timestamp}, price #{price}")
        query_map = QueryMap.insert(state.query_map, timestamp, price)
        {:continue, %{state | buffer: <<>>, query_map: query_map}}

      {:ok, :query, min_timestamp, max_timestamp} ->
        Logger.info(
          "Querying payload: min_timestamp #{min_timestamp}, max_timestamp #{max_timestamp}"
        )

        query_map = QueryMap.query(state.query_map, min_timestamp, max_timestamp)

        total_price = Enum.reduce(query_map, 0, fn {_timestamp, price}, acc -> price + acc end)
        mean_price = floor(total_price / max(QueryMap.length(query_map), 1))

        Socket.send(socket, <<mean_price::size(32)>>)
        {:continue, %{state | buffer: <<>>}}

      :error ->
        Logger.info("Unknown payload: #{inspect(payload)}")
        Socket.close(socket)
        {:close, state}
    end
  end

  def decode_payload(<<"I", timestamp::integer-signed-size(32), price::integer-signed-size(32)>>) do
    {:ok, :insert, timestamp, price}
  end

  def decode_payload(
        <<"Q", min_timestamp::integer-signed-size(32), max_timestamp::integer-signed-size(32)>>
      ) do
    {:ok, :query, min_timestamp, max_timestamp}
  end

  def decode_payload(_payload) do
    :error
  end
end
