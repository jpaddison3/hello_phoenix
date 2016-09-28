defmodule HelloPhoenix.Book do
  use HelloPhoenix.Web, :model

  schema "books" do
    field :name, :string
    field :most_recent_chapter, :string
    field :home_url, :string
    field :rss_url, :string
    field :file_location, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :most_recent_chapter, :home_url, :rss_url, :file_location])
    |> validate_required([:name, :most_recent_chapter, :home_url, :rss_url, :file_location])
  end
end
