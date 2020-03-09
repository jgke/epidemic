defmodule Epidemic.MixProject do
  use Mix.Project

  def project do
    [
      app: :epidemic,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:graphvix, "~> 1.0.0"},
      {:stream_data, "~> 0.1", only: [:dev, :test, :prod]},
      {:exprof, "~> 0.2.0"},
      {:flow, "~> 1.0"}
    ]
  end

  defp escript do
    [main_module: Epidemic]
  end
end
