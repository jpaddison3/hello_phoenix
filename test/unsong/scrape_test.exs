defmodule ScrapeTest do
  use ExUnit.Case
  require EEx
  @toc_example "test/resources/fake-unsong-toc.html.eex"
  
  doctest UnsongScraper

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass}
  end

  EEx.function_from_file :def, :get_toc, @toc_example, [:bypass_port]
  
  test "scrape_toc good path", %{bypass: bypass} do
    toc_resp = get_toc(bypass.port)
    # File.read!(@toc_example)
    # move toc to .html.eex and render to dynamically insert bypass.port, which changes
    Bypass.expect bypass, fn conn ->
      assert "GET" == conn.method
      if conn.request_path == "/table-of-contents/" do
        Plug.Conn.resp(conn, 200, toc_resp)
      else
        Plug.Conn.resp(conn, 200, ~s(<div class="pjgm-postcontent"> <p>foo bar</p> </div>))
      end
    end
    IO.puts(bypass.port)
    book = UnsongScraper.scrape_toc("localhost:#{bypass.port}/table-of-contents/")
    IO.puts("got book:")
    IO.puts(book)
    IO.puts("fin")
  end
end
