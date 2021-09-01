defmodule Sneeze.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ShaneKilkelly/sneeze"
  @version "1.2.0"

  def project do
    [
      app: :sneeze,
      version: @version,
      elixir: "~> 1.6",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:html_entities]]
  end

  defp deps do
    [
      {:html_entities, "0.4.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      description: "Render Elixir data to HTML. Inspired by Hiccup.",
      name: :sneeze,
      maintainers: ["Shane Kilkelly"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ShaneKilkelly/sneeze"}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
