defmodule GithubUserSearch.UserApi do
  @moduledoc """
  An implementation of a GithubUserSearch.UserApiBehaviour
  """
  require Logger

  @behaviour GithubUserSearch.UsersAPI

  @base_url "api.github.com"

  @spec fetch_user(binary()) :: {:ok, map()} | {:error, binary()}

  def fetch_user(username) when is_binary(username) do
    url = "https://#{@base_url}/users/#{username}"
    Logger.info("[GitHub API] GET #{url}")

    build_req = Finch.build(:get, url)

    case Finch.request(build_req, GithubUserSearch.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        response = Jason.decode!(body, keys: :atoms)
        Logger.info("[GitHub API] OK 200: #{inspect(response)}")
        {:ok, response}

      {:ok, %Finch.Response{status: 404, body: body}} ->
        response = Jason.decode!(body, keys: :atoms)
        Logger.warning("[GitHub API] Error 404: #{response.message}")
        {:error, response.message}

      {:ok, %Finch.Response{status: 403, body: body}} ->
        response = Jason.decode!(body, keys: :atoms)
        Logger.info("[GitHub API] Error 403: #{response.message}")
        {:error, response.message}

      {:error, exception} ->
        Logger.error("[GitHub API] Exception: #{inspect(exception)}")
        {:error, "An exception occurred!"}
    end
  end

  def dummy_data do
    %{
      "id" => 98_017_711,
      "name" => nil,
      "type" => "User",
      "location" => nil,
      "url" => "https://api.github.com/users/akinyiv",
      "avatar_url" => "https://avatars.githubusercontent.com/u/98017711?v=4",
      "bio" => nil,
      "blog" => "https://github.com/akinyiv",
      "company" => nil,
      "created_at" => "2022-01-19T09:03:31Z",
      "followers" => 16,
      "following" => 11,
      "html_url" => "https://github.com/akinyiv",
      "login" => "akinyiv",
      "public_repos" => 28,
      "twitter_username" => "velmah_akinyi",
      "email" => nil,
      "node_id" => "U_kgDOBdehrw",
      "gravatar_id" => "",
      "followers_url" => "https://api.github.com/users/akinyiv/followers",
      "following_url" => "https://api.github.com/users/akinyiv/following{/other_user}",
      "gists_url" => "https://api.github.com/users/akinyiv/gists{/gist_id}",
      "starred_url" => "https://api.github.com/users/akinyiv/starred{/owner}{/repo}",
      "subscriptions_url" => "https://api.github.com/users/akinyiv/subscriptions",
      "organizations_url" => "https://api.github.com/users/akinyiv/orgs",
      "repos_url" => "https://api.github.com/users/akinyiv/repos",
      "events_url" => "https://api.github.com/users/akinyiv/events{/privacy}",
      "received_events_url" => "https://api.github.com/users/akinyiv/received_events",
      "site_admin" => false,
      "hireable" => nil,
      "public_gists" => 0,
      "updated_at" => "2024-01-05T05:36:55Z"
    }
  end
end
