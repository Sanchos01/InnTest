defmodule InnTestWeb.PageController do
  use InnTestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
