defmodule GithubUserSearch.Repo do
  use Ecto.Repo,
    otp_app: :github_user_search,
    adapter: Ecto.Adapters.Postgres
end
