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
    case state.buffer <> data do
      <<payload::binary-size(9)>> ->
        Process.send(self(), {:payload, payload}, [])
        {:continue, %{state | buffer: ""}}

      <<payload::binary-size(9), rest::binary>> ->
        Process.send(self(), {:payload, payload}, [])
        handle_data(rest, socket, %{state | buffer: ""})

      data ->
        {:continue, %{state | buffer: data}}
    end
  end

  @impl GenServer
  def handle_info({:payload, payload}, {socket, state}) do
    case decode_payload(payload) do
      {:ok, :insert, timestamp, price} ->
        Logger.info("Inserting payload: timestamp #{timestamp}, price #{price}")
        query_map = QueryMap.insert(state.query_map, timestamp, price)
        {:noreply, {socket, %{state | query_map: query_map}}}

      {:ok, :query, min_timestamp, max_timestamp} ->
        Logger.info(
          "Querying payload: min_timestamp #{min_timestamp}, max_timestamp #{max_timestamp}"
        )

        query_map = QueryMap.query(state.query_map, min_timestamp, max_timestamp)

        total_price = Enum.reduce(query_map, 0, fn {_timestamp, price}, acc -> price + acc end)
        mean_price = floor(total_price / max(QueryMap.length(query_map), 1))

        Socket.send(socket, <<mean_price::size(32)>>)
        {:noreply, {socket, state}}

      :error ->
        Logger.info("Unknown payload: #{inspect(payload)}")
        Socket.close(socket)
        {:stop, :shutdown, {socket, state}}
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
