defmodule LiveCounterWeb.ClickerComponent do
  use LiveCounterWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, clicks: 0)}
  end

  def handle_event("click", _, socket) do
    {:noreply, update(socket, :clicks, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <div>
      Component clicks: <%= @clicks %>
      <button phx-click="click" phx-target={@myself}>
        Click me
      </button>
    </div>
    """
  end
end
