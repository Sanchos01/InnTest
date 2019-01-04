defmodule InnTestWeb.RoomChannel do
  use InnTestWeb, :channel
  alias InnTest.SimpleHistory
  require Logger

  def join("room:lobby", _msg, socket) do
    send self(), :after_connect
    {:ok, socket}
  end

  def handle_info(:after_connect, socket) do
    history = SimpleHistory.get_history()
    push socket, "history", %{history: history}
    {:noreply, socket}
  end

  def handle_in("new_inn", %{"body" => inn}, socket) do
    case SimpleHistory.new(inn) do
      res when is_boolean(res) ->
        {:reply, {:ok, %{result: res}}, socket}
      errors = [_|_] ->
        {:reply, {:error, %{errors: errors}}, socket}
      :error ->
        {:reply, {:error, %{errors: ["unknown error"]}}, socket}
    end
  end
end