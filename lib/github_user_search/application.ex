defmodule GithubUserSearch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GithubUserSearchWeb.Telemetry,
      GithubUserSearch.Repo,
      {DNSCluster,
       query: Application.get_env(:github_user_search, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GithubUserSearch.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GithubUserSearch.Finch},
      {Finch, name: GithubUserSearch.UserAPI},

      # Start a worker by calling: GithubUserSearch.Worker.start_link(arg)
      # {GithubUserSearch.Worker, arg},
      # Start to serve requests, typically the last entry
      GithubUserSearchWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GithubUserSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GithubUserSearchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
