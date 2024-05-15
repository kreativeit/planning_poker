import Config

config :web, Web.Endpoint, url: [host: "localhost", port: System.get_env("PORT", "4000")]

config :logger, level: :info

config :libcluster,
  topologies: [
    fly6pn: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        polling_interval: 5_000,
        node_basename: app_name,
        query: "#{app_name}.internal"
      ]
    ]
  ]

config :core, Core.Session.Server,
  heartbeat_interval_milliseconds: :timer.seconds(5),
  max_session_duration_milliseconds: :timer.minutes(30)
