defmodule Eostorage.Mixfile do
  use Mix.Project

  def project do
    [app: :eostorage,
     description: "elixir online storage",
     version: "0.1.0",
     elixir: "~> 1.4-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env),
     escript: escript()
     ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: app(Mix.env),
     mod: {Eostorage, []},
     env: [ttl: 5000, check_timeout: 250]]
    #value of ttl: 5000, check_timeout: 250 in miliseconds here
  end

  defp app :test do
    [:logger, :cowboy, :httpotion]
  end
  defp app _ do
    [:logger, :cowboy]
  end
  defp deps :test do
    [{:httpotion, "~> 3.0.0"} | deps(:def)]
  end
  defp deps _ do
    [{:cowboy, git: "https://github.com/ninenines/cowboy.git", tag: "1.0.1"},
     {:jsx, git: "https://github.com/sergey-ivlev/jsx.git", branch: "develop"},
     {:etslib, git: "https://github.com/sergey-ivlev/etslib.git", branch: "master"},
     {:elixir_monad, git: "https://github.com/nickmeharry/elixir-monad.git", app: false}
     ]
  end

  defp escript do
    [main_module: Eostorage]
  end
end
