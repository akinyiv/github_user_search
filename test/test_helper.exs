Mox.defmock(GithubUserSearch.ClientMock, for: GithubUserSearch.Client)
Application.put_env(:github_user_search, :github_user_search_client, GithubUserSearch.ClientMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GithubUserSearch.Repo, :manual)
