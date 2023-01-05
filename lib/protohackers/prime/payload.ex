defmodule Protohackers.Prime.Payload do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  embedded_schema do
    field :method, :string
    field :number, :integer
  end

  @spec changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(payload_or_changeset, params \\ %{}) do
    payload_or_changeset
    |> cast(params, [:method, :number])
    |> validate_required([:method, :number])
    |> validate_allowed_method()
  end

  defp validate_allowed_method(changeset) do
    value = get_field(changeset, :method)

    if value == "isPrime" do
      changeset
    else
      add_error(changeset, :method, "method field has invalid value")
    end
  end
end
