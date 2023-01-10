import Config

# Configure options for the UDP server.
# Production configuration will bind to a special host address,
# as fly.io requires UDP traffic to bind to this address.
config :protohackers,
  udp_options: [
    host: "fly-global-services",
    port: 5000
  ]
