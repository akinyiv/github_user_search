defmodule GithubUserSearch.UsersAPI do
  @moduledoc false
  alias GithubUserSearch.UserAPI
  @callback fetch_user(binary()) :: {:ok, map()} | {:error, binary()}

  def fetch_user(username), do: impl().fetch_user(username)

  defp impl(),
    do:
      Application.get_env(
        :github_user_search,
        :github_user_search_client,
        UserAPI
      )
end
