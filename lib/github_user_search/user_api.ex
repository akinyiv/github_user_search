defmodule GithubUserSearch.UserAPI do
  @moduledoc """
  An implementation of a GithubUserSearch.UserAPIBehaviour
  """
  require Logger

  @behaviour GithubUserSearch.UsersAPI

  @base_url "https://api.github.com/users/"

  @impl GithubUserSearch.UsersAPI

  def fetch_user(username) do
    username
    |> request_profile
    |> handle_response
  end

  defp request_profile(username) do
    :get
    |> Finch.build(@base_url <> username)
    |> Finch.request(__MODULE__)
  end

  defp handle_response({:ok, %Finch.Response{body: body, status: 200}}) do
    response = Jason.decode!(body)

    {:ok, response}
  end

  defp handle_response({:ok, %Finch.Response{status: 404}}) do
    {:ok, "Not Found"}
  end

  defp handle_response({:error, reason}) do
    Logger.error(reason)
    {:error, reason}
  end

  # defp handle_response(:ok, %Finch.Response{body: body, status: status}) do
  #   Logger.error("Github API error: #{inspect(body)} #{status}")
  #   {:error, "Github API error"}
  # end
end
