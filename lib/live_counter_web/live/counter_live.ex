defmodule LiveCounterWeb.CounterLive do
  use LiveCounterWeb, :live_view

  # import LiveCounterWeb.CoreComponents

  # ---------- Changeset ----------

  alias LiveCounter.Counter

def changeset(%Counter{} = counter, params) do
  {counter, %{value: :integer}}
  |> Ecto.Changeset.cast(params, [:value])
  |> Ecto.Changeset.validate_required([:value])
  |> Ecto.Changeset.validate_number(:value, greater_than: 0)
end


  # ---------- Mount ----------

  def mount(_params, _session, socket) do
  counter = %Counter{value: nil}
  changeset = changeset(counter, %{})

  {:ok,
   assign(socket,
     count: 0,
     counter: counter,
     changeset: changeset
   )}
end



  # ---------- Render ----------

  def render(assigns) do
    ~H"""
    <h1>Counter: <%= @count %></h1>

    <button phx-click="dec">-</button>
    <.simple_button phx-click="inc">+</.simple_button>

    <hr />

    <.form
  let={f}
  for={@changeset}
  phx-change="validate"
  phx-submit="save">

  <%= label f, :value %>
  <%= number_input f, :value %>
  <%= error_tag f, :value %>

  <button>Set Counter</button>
</.form>



    <hr />

    <.live_component
      module={LiveCounterWeb.ClickerComponent}
      id="clicker"
    />
    """
  end


  # ---------- Events ----------

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_event("validate", %{"counter" => params}, socket) do
  changeset =
    socket.assigns.counter
    |> changeset(params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, changeset: changeset)}
end



  def handle_event("save", %{"counter" => %{"value" => v}}, socket) do
  {:noreply, assign(socket, count: String.to_integer(v))}
end




  # ---------- Background ----------

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  # ---------- Function Component ----------

  def simple_button(assigns) do
    ~H"""
    <button class="px-3 py-1 border rounded">
      <%= render_slot(@inner_block) %>
    </button>
    """
  end
end
