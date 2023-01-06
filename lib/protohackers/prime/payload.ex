defmodule Protohackers.Prime.Payload do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @allowed_method "isPrime"

  embedded_schema do
    field :method, :string
    field :number, :integer
  end

  @spec changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(payload_or_changeset, params \\ %{}) do
    payload_or_changeset
    |> cast(params, [:method])
    |> cast_number(params)
    |> validate_required([:method, :number])
    |> validate_allowed_method()
  end

  defp cast_number(changeset, params) do
    number = Map.get(params, "number")

    cond do
      is_float(number) ->
        put_change(changeset, :number, trunc(number))

      is_integer(number) ->
        put_change(changeset, :number, number)

      true ->
        add_error(changeset, :number, "number field is not an integer")
    end
  end

  defp validate_allowed_method(changeset) do
    value = get_field(changeset, :method)

    if value == @allowed_method do
      changeset
    else
      add_error(changeset, :method, "method field has invalid value")
    end
  end
end
