defmodule InnTest.Inn do
  use Ecto.Schema
  import Ecto.Changeset
  import InnTest.InnValidation, only: [validate: 1]

  schema "inns" do
    field :inn, :string
    field :valid, :boolean

    timestamps(
      updated_at: nil
    )
  end

  @keys ~w(inn)a

  def changeset(inn = %__MODULE__{}, attrs) do
    inn
    |> cast(attrs, @keys)
    |> validate_required(@keys)
    |> validate_change(:inn, fn :inn, inn ->
      if inn =~ ~r/^\d{10}$/ or inn =~ ~r/^\d{12}$/ do
        []
      else
        [inn: "wrong format inn"]
      end
    end)
    |> maybe_add_valid()
  end

  defp maybe_add_valid(chng = %{valid?: false}), do: chng
  defp maybe_add_valid(chng) do
    inn = chng.changes.inn
    valid = validate(inn)
    cast(chng, %{valid: valid}, [:valid])
  end
end