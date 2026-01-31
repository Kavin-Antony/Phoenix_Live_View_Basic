defmodule LvBasicsWeb.CounterLive do
  use LvBasicsWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
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
    <button phx-click="dec">-</button>
    <button phx-click="inc">+</button>
    <br>
    <.link patch={~p"/counter?mode=normal"}>Normal</.link>
    |
    <.link patch={~p"/counter?mode=fast"}>Fast</.link>
    <p>Mode: <%= @mode %></p>

    <hr />

    <h3>Set counter value</h3>

    <.form

      :let={f}
      for={@changeset}
      as={:value}
      phx-change="validate"
      phx-submit="save">


      <.input
        field={f[:value]}
        type="number"
        label="Value" />

      <button>Update</button>
    </.form>

    """
  end

  def handle_event("inc", _unsigned_params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _unsigned_params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_event("validate", %{"value" => params}, socket) do
    changeset =
      changeset(%{}, params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"value" => %{"value" => value}}, socket) do
    new_changeset = changeset(%{}, %{})

    {:noreply,
    assign(socket,
      count: String.to_integer(value),
      changeset: new_changeset
    )}
  end

  # def handle_info(:tick, socket) do
  #   {:noreply, update(socket, :count, &(&1 + 1))}
  # end

  def handle_info(:tick, socket) do
    increment =
      case socket.assigns.mode do
        :fast -> 5
        _ -> 1
      end

    {:noreply, update(socket, :count, &(&1 + increment))}
  end


  def handle_params(%{"mode" => "fast"}, _, socket) do
    {:noreply, assign(socket, mode: :fast)}
  end

  def handle_params(_, _, socket) do
    {:noreply, assign(socket, mode: :normal)}
  end

  defp changeset(data, params) do
    {data, %{value: :integer}}
    |> Ecto.Changeset.cast(params, [:value])
    |> Ecto.Changeset.validate_required([:value])
    |> Ecto.Changeset.validate_number(:value, greater_than_or_equal_to: 0)
  end


end
