defmodule Protohackers.Prime.Handler do
  use ThousandIsland.Handler

  alias ThousandIsland.Socket
  alias Protohackers.Prime.Payload

  import Protohackers.Prime

  require Logger

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    {outcome, response} = handle_payload(data)
    Socket.send(socket, response)
    {outcome, state}
  end

  def handle_payload(data) do
    with {:ok, object} <- Jason.decode(data),
         changeset <- Payload.changeset(%Payload{}, object),
         true <- changeset.valid?,
         payload <- Ecto.Changeset.apply_changes(changeset),
         response <- Jason.encode!(%{"method" => "isPrime", "prime" => prime?(payload.number)}) do
      {:continue, with_newline(response)}
    else
      _ ->
        {:close, with_newline("malformed response")}
    end
  end

  defp with_newline(binary), do: binary <> "\n"
end
