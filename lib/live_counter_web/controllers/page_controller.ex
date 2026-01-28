defmodule LiveCounterWeb.PageController do
  use LiveCounterWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
