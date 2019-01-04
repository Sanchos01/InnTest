defmodule InnTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ok = setup_db!()
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      InnTest.Repo,
      # Start the endpoint when the application starts
      InnTestWeb.Endpoint,
      InnTest.SimpleHistory,
      # Starts a worker by calling: InnTest.Worker.start_link(arg)
      # {InnTest.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InnTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    InnTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Setup Sqlite db
  defp setup_db! do
    repos = Application.get_env(:inn_test, :ecto_repos)
    for repo <- repos do
      setup_repo!(repo)
      migrate_repo!(repo)
    end
    :ok
  end

  defp setup_repo!(repo) do
    db_file = Application.get_env(:inn_test, repo)[:database]
    unless File.exists?(db_file) do
      :ok = repo.__adapter__.storage_up(repo.config)
    end
  end

  defp migrate_repo!(repo) do
    opts = [all: true]
    {:ok, pid, apps} = Mix.Ecto.ensure_started(repo, opts)

    pool = repo.config[:pool]
    migrations_path = Path.join([:code.priv_dir(:inn_test) |> to_string, "repo", "migrations"])
    migrated =
      if function_exported?(pool, :unboxed_run, 2) do
        pool.unboxed_run(repo, fn -> Ecto.Migrator.run(repo, migrations_path, :up, opts) end)
      else
        Ecto.Migrator.run(repo, migrations_path, :up, opts)
      end

    pid && repo.stop(pid)
    Mix.Ecto.restart_apps_if_migrated(apps, migrated)
  end
end
