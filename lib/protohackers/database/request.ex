defmodule Protohackers.Database.Request do
  @moduledoc """
  Module for defining a database request around decoding incoming
  payload from a client.
  """

  @spec decode_payload(binary) ::
          {:ok, :insert, binary, binary}
          | {:ok, :retrieve, binary}
          | {:ok, :version}
          | :error
  def decode_payload(payload)

  def decode_payload(payload) when not is_binary(payload),
    do: :error

  def decode_payload("version") do
    {:ok, :version}
  end

  def decode_payload("version" <> "=" <> _) do
    :error
  end

  def decode_payload(payload) do
    if String.contains?(payload, "=") do
      [key, value] = String.split(payload, "=", parts: 2)
      {:ok, :insert, key, value}
    else
      {:ok, :retrieve, payload}
    end
  end
end
