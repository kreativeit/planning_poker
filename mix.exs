defmodule PlanningPoker.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      version: "0.1.0",
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: [
        planning_poker: [
          applications: [
            web: :permanent,
            core: :permanent
          ]
        ]
      ]
    ]
  end

  defp deps do
    [
      {:distillery, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      setup: ["cmd mix setup"]
    ]
  end
end
