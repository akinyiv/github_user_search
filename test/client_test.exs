defmodule GithubUserSearch.ClientTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @response %{
    "login" => "validuser",
    "avatar_url" => "https://avatars.githubusercontent.com/u/321999?v=4",
    "name" => nil,
    "html_url" => "https://github.com/validuser",
    "bio" => nil,
    "created_at" => "2010-07-03T17:11:21Z",
    "public_repos" => 0,
    "followers" => 0,
    "following" => 0,
    "location" => nil,
    "blog" => "",
    "twitter_username" => nil,
    "company" => nil,
    "email" => nil,
    "events_url" => "https://api.github.com/users/validuser/events{/privacy}",
    "followers_url" => "https://api.github.com/users/validuser/followers",
    "following_url" => "https://api.github.com/users/validuser/following{/other_user}",
    "gists_url" => "https://api.github.com/users/validuser/gists{/gist_id}",
    "gravatar_id" => "",
    "hireable" => nil,
    "id" => 321_999,
    "node_id" => "MDQ6VXNlcjMyMTk5OQ==",
    "organizations_url" => "https://api.github.com/users/validuser/orgs",
    "public_gists" => 0,
    "received_events_url" => "https://api.github.com/users/validuser/received_events",
    "repos_url" => "https://api.github.com/users/validuser/repos",
    "site_admin" => false,
    "starred_url" => "https://api.github.com/users/validuser/starred{/owner}{/repo}",
    "subscriptions_url" => "https://api.github.com/users/validuser/subscriptions",
    "type" => "User",
    "updated_at" => "2015-04-09T20:00:14Z",
    "url" => "https://api.github.com/users/validuser"
  }

  describe "fetch_user/1" do
    test "returns user info on success" do
      GithubUserSearch.ClientMock
      |> expect(:fetch_user, fn "validuser" ->
        {:ok, @response}
      end)

      assert {:ok, @response} = GithubUserSearch.Client.fetch_user("validuser")
    end

    test "returns not found error" do
      GithubUserSearch.ClientMock
      |> expect(:fetch_user, fn "invaliduser" -> {:error, "Github API error"} end)

      assert {:error, "Github API error"} = GithubUserSearch.Client.fetch_user("invaliduser")
    end

    test "handles API rate limit error" do
      GithubUserSearch.ClientMock
      |> expect(:fetch_user, fn "ratelimiteduser" -> {:error, "API rate limit exceeded"} end)

      assert {:error, "API rate limit exceeded"} =
               GithubUserSearch.Client.fetch_user("ratelimiteduser")
    end

    test "handles general API error" do
      GithubUserSearch.ClientMock
      |> expect(:fetch_user, fn "erroruser" -> {:error, "Github API error"} end)

      assert {:error, "Github API error"} = GithubUserSearch.Client.fetch_user("erroruser")
    end
  end
end
