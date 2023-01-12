import Config

# Configure options for the TCP server.
config :protohackers,
  tcp_options: [
    port: 5001,
    read_timeout: 100
  ]
