defmodule HelloPhoenix.BookController do
  use HelloPhoenix.Web, :controller

  alias HelloPhoenix.Book

  def index(conn, _params) do
    books = Repo.all(Book)
    render(conn, "index.html", books: books)
  end
end

