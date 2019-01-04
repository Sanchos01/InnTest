defmodule InnTest.SimpleHistory do
  use GenServer
  alias InnTest.{Inn, Repo}
  alias InnTestWeb.Endpoint
  import Ecto.Query
  require Logger

  @limit 10

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_) do
    history = preload()
    {:ok, %{history: history}}
  end

  def get_history(), do: GenServer.call(__MODULE__, :get_history)
  def new(inn),      do: GenServer.call(__MODULE__, {:new, inn})

  def handle_call(:get_history, _from, state) do
    {:reply, state.history, state}
  end

  def handle_call({:new, inn}, _from, state = %{history: history}) do
    with chng = %{valid?: true} <- Inn.changeset(%Inn{}, %{inn: inn}),
         {:ok, obj} <- Repo.insert(chng)
    do
      new_history = [format(obj) | Enum.take(history, @limit - 1)]
      {:reply, obj.valid, %{history: new_history}, {:continue, :broadcast}}
    else
      chng = %{valid?: false} ->
        {:reply, format_errors(chng), state}
      error ->
        Logger.error "unhandled error: #{inspect error}"
        {:reply, :error, state}
    end
  end

  def handle_continue(:broadcast, state) do
    Endpoint.broadcast "room:lobby", "new_inn", hd(state.history)
    {:noreply, state}
  end

  defp preload() do
    for inn <- Repo.all(from i in Inn, order_by: [desc: i.id], limit: @limit) do
      format(inn)
    end
  end

  defp format(inn) do
    %{time: format_time(inn.inserted_at), inn: inn.inn, valid: inn.valid}
  end

  defp format_time(t), do: Timex.format!(t, "%-e.%-m.%Y %H:%M", :strftime)

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {e, _} -> e end)
    |> Enum.reduce([], fn {key, errors}, acc ->
      str_errors = Enum.reduce(errors, fn e, acc -> acc <> ", " <> e end)
      ["#{key}: " <> str_errors | acc]
    end)
  end
end
