defmodule Protohackers.Prime.Callback do
  @behaviour Protohackers.TcpServer.Callback

  alias Protohackers.Prime.Payload

  import Protohackers.Prime

  @impl true
  @spec handle_data(binary) :: {:continue, binary} | {:stop, binary}
  def handle_data(data) do
    with {:ok, object} <- Jason.decode(data),
         changeset <- Payload.changeset(%Payload{}, object),
         true <- changeset.valid?,
         payload <- Ecto.Changeset.apply_changes(changeset),
         {:ok, response} <-
           Jason.encode(%{"method" => "isPrime", "prime" => is_prime(payload.number)}) do
      {:continue, with_newline(response)}
    else
      _ ->
        malformed_response = Jason.encode!(%{"method" => "isPrime", "prime" => "1"})
        {:stop, with_newline(malformed_response)}
    end
  end

  defp with_newline(binary), do: binary <> "\n"
end
