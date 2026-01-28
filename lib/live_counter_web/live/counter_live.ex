defmodule LiveCounterWeb.CounterLive do
  use LiveCounterWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign(socket, count: 0)}
  end


  def render(assigns) do
    ~H"""
    <h1>Counter: <%= @count %></h1>

    <button phx-click="dec">-</button>
    <button phx-click="inc">+</button>
    """
  end

  def handle_event("inc", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("dec", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_info(:tick, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end




end
