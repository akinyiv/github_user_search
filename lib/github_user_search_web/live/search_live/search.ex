defmodule GithubUserSearchWeb.SearchLive do
  use GithubUserSearchWeb, :live_view
  alias GithubUserSearch.UserApi
  alias GithubUserSearchWeb.SearchLive.Components

  @moduledoc false

  def mount(_params, _session, socket) do
    user = UserApi.dummy_data()
    form = to_form(%{"username" => ""})
    {:ok, assign(socket, user: user, form: form)}
  end

  def render(assigns) do
    ~H"""
    <div class="place-content-center bg-[#F6F8FF] dark:bg-[#141D2F]">
      <div class="flex items-center justify-between">
        <h1 class="ml-6 font-bold text-[#222731] dark:text-[#FFFFFF]">devfinder</h1>
        <button phx-click={toggle_dark_mode()}>
          <div id="dark-mode" class="hidden gap-2 text-[#FFFFFF]">
            <h2>LIGHT</h2>
            <.icon name="hero-sun-solid" />
          </div>
          <div id="light-mode" class="flex gap-2 text-[#4B6A9B]">
            <h2>DARK</h2>
            <.icon name="hero-moon-solid" />
          </div>
        </button>
      </div>

      <Components.search_form form={@form} />

      <div class="flex py-6 px-10 mx-6 my-10 rounded-sm bg-[#FEFEFE dark:bg-[#1E2A47]">
        <div class="flex gap-4">
          <img src={@user["avatar_url"]} alt="" class="w-[80px] h-[80px] rounded-full" />
        </div>
        <div class="ml-6">
          <div class="flex justify-between">
            <div>
              <h2 class="text-#2B3442 dark:text-[#FFFFFF] font-bold">
                <%= @user["name"] || @user["login"] %>
              </h2>
              <p class="text-[#0079FF]">@<%= @user["login"] %></p>
            </div>
            <p class="text-[#697C9A] dark:text-[#FFFFFF]">
              <%= "Joined #{format_date(@user["created_at"])}" %>
            </p>
          </div>
          <p class="text-[#4B6A9B] dark:text-[#FFFFFF] my-4">
            <%= @user["bio"] || "This profile has no bio" %>
          </p>
          <div class="flex justify-between bg-[#141D2F] rounded-lg my-8 px-6 py-2">
            <div class="text-[#4B6A9B] dark:text-[#FFFFFF]">
              <p>Repos</p>
              <span><%= @user["public_repos"] %></span>
            </div>
            <div class="text-[#4B6A9B] dark:text-[#FFFFFF]">
              <p>Followers</p>
              <span><%= @user["public_repos"] %></span>
            </div>
            <div class="text-[#4B6A9B] dark:text-[#FFFFFF]">
              <p>Following</p>
              <span><%= @user["following"] %></span>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-6 text-[#4B6A9B] dark:text-[#FFFFFF]">
            <div class="flex items-center">
              <Components.location_icon />
              <p class="ml-2"><%= @user["location"] %></p>
            </div>
            <div class="flex items-center">
              <Components.twitter_icon account_exist?={@user["twitter_username"]} />
              <p class="ml-2"><%= @user["twitter_username"] %></p>
            </div>
            <div class="flex items-center">
              <Components.link_icon />
              <p class="ml-2"><%= @user["blog"] %></p>
            </div>
            <div class="flex items-center">
              <Components.office_icon />
              <p class="ml-2"><%= @user["company"] %></p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("search_user", %{"username" => username}, socket) do
    case UserApi.fetch_user(username) do
      {:ok, user} ->
        form = to_form(%{"username" => ""})
        socket = put_flash(socket, :info, "user profile fetched successfully")
        {:noreply, assign(socket, user: user, form: form)}

      {:error, error} ->
        form = to_form(%{"username" => ""})
        socket = put_flash(socket, :error, error)
        {:noreply, assign(socket, form: form)}
    end
  end

  defp toggle_dark_mode do
    JS.dispatch("toogle-darkmode")
    |> JS.toggle(to: "#dark-mode", display: "flex")
    |> JS.toggle(to: "#light-mode", display: "flex")
  end

  defp format_date(nil), do: "Unknown"

  defp format_date(date) do
    {:ok, utc_time, _int} = DateTime.from_iso8601(date)

    utc_time
    |> DateTime.to_date()
    |> Timex.format!("{D} {Mshort} {YYYY}")
  end
end
