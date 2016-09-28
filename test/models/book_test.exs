defmodule HelloPhoenix.BookTest do
  use HelloPhoenix.ModelCase

  alias HelloPhoenix.Book

  @valid_attrs %{file_location: "some content", home_url: "some content",
                 most_recent_chapter: "some content", name: "some content",
                 rss_url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Book.changeset(%Book{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Book.changeset(%Book{}, @invalid_attrs)
    refute changeset.valid?
  end
end
