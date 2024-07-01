defmodule GithubUserSearchWeb.SearchLive.Index do
  use GithubUserSearchWeb, :live_view
  alias GithubUserSearch.Client
  alias GithubUserSearch.Username
  alias GithubUserSearchWeb.SearchLive.Components

  @moduledoc false

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-between items-center mb-8">
      <h1 class="font-bold text-[#222731] dark:text-[#fff] text-base">devfinder</h1>
      <div>
        <button
          class="uppercase font-bold tracking-widest dark:hidden flex gap-2 items-center"
          phx-click={JS.dispatch("toggle-theme")}
        >
          <span>Dark</span>
          <Components.moon_icon />
        </button>

        <button
          class="uppercase font-bold tracking-widest hidden dark:flex dark:hover:text-[#90A4D4] dark:gap-2 dark:items-center"
          phx-click={JS.dispatch("toggle-theme")}
        >
          <span class="dark:text-[#fff]">Light</span>
          <Components.sun_icon />
        </button>
      </div>
    </div>

    <div class="bg-[#FEFEFE] dark:bg-[#1E2A47] rounded-lg mb-4">
      <.form
        for={@form}
        class="flex items-center justify-between w-full p-2 "
        phx-change="validate"
        phx-submit="search_dev"
        id="search_form"
      >
        <Components.search_icon class="" />
        <.input
          field={@form[:username]}
          phx-debounce="blur"
          placeholder="Search GitHub username..."
          class="w-full border-none bg-[#FEFEFE] dark:bg-[#1E2A47]
          placeholder:text-[#4B6A9B] dark:placeholder:text-[#FFFFFF]"
        />

        <.button class="">search</.button>
      </.form>
    </div>

    <div class="mt-3 px-8 py-6 max-w-2xl rounded-xl bg-white dark:bg-[#1E2A47]">
      <div class="flex p-2">
        <img
          src={@dev_info["avatar_url"]}
          alt={@dev_info["name"]}
          class="h-16 w-16 rounded-full mr-2 profile-logo"
        />
        <div>
          <h2 class="font-bold text-[#2b3442] dark:text-white text-lg tracking-wider profile-name">
            <%= @dev_info["name"] %>
          </h2>
          <.link href={@dev_info["html_url"]} class="text-[#0079ff] hover:opacity-75 profile-link">
            @<%= @dev_info["login"] %>
          </.link>
          <p class="tracking-wider dark:text-[#fff]"><%= @dev_info["bio"] %></p>

          <div justify-end>
            <p class="dark:text-[#fff]">Joined <%= process_date(@dev_info["created_at"]) %></p>
          </div>
        </div>
      </div>

      <div class="p-4 mt-2 rounded-md bg-[#f6f8ff] dark:bg-[#141D2F] flex gap-20 profile-stats dark:text-[#fff]">
        <p class="flex flex-col">
          <span class="text-sm dark:opacity-80 mb-3"> Repos </span>
          <span class="text-[#2b3442] dark:text-[#fff] font-bold">
            <%= @dev_info["public_repos"] %>
          </span>
        </p>
        <p class="flex flex-col ">
          <span class="text-sm dark:opacity-80 mb-3"> Followers </span>
          <span class="text-[#2b3442] dark:text-[#fff] font-bold"><%= @dev_info["followers"] %></span>
        </p>
        <p class="flex flex-col">
          <span class="text-sm dark:opacity-80 mb-3"> Following </span>
          <span class="text-[#2b3442] dark:text-[#fff] font-bold"><%= @dev_info["following"] %></span>
        </p>
      </div>

      <div class="p-4 mt-2 columns-2 dark:text-[#fff]">
        <div class={["flex gap-2 items-center mb-3", @dev_info["location"] == "" && "opacity-50"]}>
          <Components.location_icon />
          <p>
            <%= check_empty_response(@dev_info["location"]) %>
          </p>
        </div>

        <div class={["flex gap-2 items-center", @dev_info["blog"] == "" && "opacity-50"]}>
          <Components.blog_icon />
          <p>
            <%= check_empty_response(@dev_info["blog"]) %>
          </p>
        </div>
        <div class={[
          "flex gap-2 items-center mb-3",
          @dev_info["twitter_username"] == "" && "opacity-50"
        ]}>
          <Components.twitter_icon />
          <p>
            <%= check_empty_response(@dev_info["twitter_username"]) %>
          </p>
        </div>
        <div class={["flex gap-2 items-center", @dev_info["company"] == "" && "opacity-50"]}>
          <Components.company_icon />
          <p>
            <%= check_empty_response(@dev_info["company"]) %>
          </p>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:current_profile, "octocat")
     |> assign(:username, %Username{})
     |> assign(:error, "")
     |> assign(:show_errors, false)
     |> assign_dev_info("octocat")
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"username" => username_params}, socket) do
    %{assigns: %{username: username}} = socket

    changeset =
      username
      |> Username.changeset(username_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:show_errors, false)}
  end

  @impl true
  def handle_event("search_dev", %{"username" => %{"username" => username}}, socket) do
    {
      :noreply,
      socket
      |> assign_dev_info(username)
    }
  end

  defp assign_dev_info(socket, dev_name) do
    case Client.fetch_user(dev_name) do
      {:ok, "Not found"} ->
        socket
        |> assign(:error, "Not found")
        |> assign(:show_errors, true)
        |> assign(:dev_info, %{})

      {:ok, dev_info} ->
        socket
        |> assign(:dev_info, dev_info)
        |> assign(:current_profile, dev_name)
        |> assign(:show_errors, false)

      {:error, _reason} ->
        socket
        |> assign(:error, "Something went wrong")
        |> assign(:show_errors, true)
        |> assign(:dev_info, %{})
    end
  end

  defp assign_form(socket) do
    %{assigns: %{username: username}} = socket

    form =
      username
      |> Username.changeset()
      |> to_form()

    assign(socket, :form, form)
  end

  defp process_date(nil), do: "Date not available"

  defp process_date(date) do
    [date, _time] = String.split(date, "T")

    [year, month, day] = String.split(date, "-")

    month =
      month
      |> String.to_integer()
      |> Timex.month_shortname()

    "#{day} #{month} #{year}"
  end

  defp check_empty_response(nil), do: "Not Available"

  defp check_empty_response(value) do
    case String.match?(value, ~r/^$/) do
      true -> "Not Available"
      false -> value
    end
  end
end
