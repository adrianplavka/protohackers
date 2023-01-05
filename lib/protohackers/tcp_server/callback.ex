defmodule Protohackers.TcpServer.Callback do
  @moduledoc """
  Behaviour for `Protohackers.TcpServer` which delegates incoming data
  to the corresponding module.

  Custom module should implement a single callback `handle_data`, which
  handles incoming data accordingly.

  This callback should return either `{:continue, data}`, which will return the
  data back to the client or `{:stop, data}`, which will also return the
  data, but close the connection.
  """

  @callback handle_data(data :: binary) ::
              {:continue, response :: binary}
              | {:stop, response :: binary}
end
