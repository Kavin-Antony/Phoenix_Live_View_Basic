defmodule LvBasicsWeb.CounterLive do
  use LvBasicsWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
      Phoenix.PubSub.subscribe(LvBasics.PubSub, "counter")
    end

    changeset = changeset(%{}, %{})

    {:ok,
     assign(socket,
       count: 0,
       mode: :normal,
       changeset: changeset
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Counter: <%= @count %></h1>
    <p>Mode: <%= @mode %></p>

    <button phx-click="dec">-</button>
    <button phx-click="inc">+</button>
    <br />
    <.link patch={~p"/counter?mode=normal"}>Normal</.link>
    | <.link patch={~p"/counter?mode=fast"}>Fast</.link>

    <hr />

    <h3>Set counter value</h3>

    <.form
      :let={f}
      for={@changeset}
      as={:value}
      phx-change="validate"
      phx-submit="save"
    >
      <.input
        field={f[:value]}
        type="number"
        label="Value"
      />

      <button>Update</button>
    </.form>
    """
  end

  def handle_event("inc", _, socket) do
    new_count = socket.assigns.count + 1

    Phoenix.PubSub.broadcast(
      LvBasics.PubSub,
      "counter",
      {:update_counter, new_count}
    )

    {:noreply, socket}
  end

  def handle_event("dec", _, socket) do
    new_count = socket.assigns.count - 1

    Phoenix.PubSub.broadcast(
      LvBasics.PubSub,
      "counter",
      {:update_counter, new_count}
    )

    {:noreply, socket}
  end

  def handle_event("validate", %{"value" => params}, socket) do
    changeset =
      changeset(%{}, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"value" => %{"value" => value}}, socket) do
    count = String.to_integer(value)

    Phoenix.PubSub.broadcast(
      LvBasics.PubSub,
      "counter",
      {:update_counter, count}
    )

    {:noreply, assign(socket, changeset: changeset(%{}, %{}))}
  end


  def handle_info({:update_counter, new_count}, socket) do
    {:noreply, assign(socket, count: new_count)}
  end

  def handle_info({:update_mode, mode}, socket) do
    {:noreply, assign(socket, mode: mode)}
  end

  def handle_info(:tick, socket) do
    increment =
      case socket.assigns.mode do
        :fast -> 5
        _ -> 1
      end

    new_count = socket.assigns.count + increment

    Phoenix.PubSub.broadcast(
      LvBasics.PubSub,
      "counter",
      {:update_counter, new_count}
    )

    {:noreply, socket}
  end


  def handle_params(%{"mode" => mode}, _, socket) when mode in ["normal", "fast"] do
    Phoenix.PubSub.broadcast(
      LvBasics.PubSub,
      "counter",
      {:update_mode, String.to_atom(mode)}
    )

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  # def handle_params(%{"mode" => "fast"}, _, socket) do
  #   {:noreply, assign(socket, mode: :fast)}
  # end

  # def handle_params(_, _, socket) do
  #   {:noreply, assign(socket, mode: :normal)}
  # end

  defp changeset(data, params) do
    {data, %{value: :integer}}
    |> Ecto.Changeset.cast(params, [:value])
    |> Ecto.Changeset.validate_required([:value])
    |> Ecto.Changeset.validate_number(:value, greater_than_or_equal_to: 0)
  end
end
