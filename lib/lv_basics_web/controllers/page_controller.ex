defmodule LvBasicsWeb.PageController do
  use LvBasicsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
