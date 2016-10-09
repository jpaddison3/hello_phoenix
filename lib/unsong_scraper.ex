defmodule UnsongScraper do
  @toc "http://unsongbook.com"
  @out "unsong.html"

  def main do
    book_html = scrape_toc(@toc)
    write_book(book_html, @out)
    :ok
  end

  def read_book(file) do
    File.read! file
  end

  def scrape_toc(link) do
    IO.puts "Scraping..."
    response = HTTPotion.get(link)
    html_tree = Floki.parse(response.body)
    ch_links = find_ch_links(html_tree)
    if length(ch_links) == 0 do
      raise "No chapters found in table of contents"
    end
    ch_texts = pmap(ch_links, &scrape_ch/1)
    ch_texts
  end

  def write_book book_html, output do
    file = File.open! output, [:write]
    try do
      IO.binwrite file, book_html
      # IO.puts(Process.info(file, :status))
      # Todo learn enough about processes to figure out how to wait on write
      Process.sleep(1000)
      # IO.puts(Process.info(file, :status))
    after
      File.close file
    end
  end

  def scrape_ch(link) do
    IO.puts link
    response = HTTPotion.get(link)
    html_tree = Floki.parse(response.body)
    text = extract_text(html_tree)
    # slice_head(text)
    text
  end

  def find_ch_links(html_tree) do
    all_links =
      html_tree
      |> Floki.find(".pjgm-postcontent")
      |> Floki.find("a")
      |> Floki.filter_out(".share-.*")
    all_links = Enum.slice(all_links, 0..2)
    links_list_filtered =
      all_links
      |> Enum.map(&get_link_url/1)
      |> Enum.filter(fn x ->
          not Regex.match?(~R(\?share=), x) and
          not Regex.match?(~R(vote.php\?for=), x)
        end)
    links_list_filtered
  end

  def get_link_url(href_tree) do
    raw =
      href_tree
      |> Floki.raw_html()
    match = Regex.named_captures(~r{"(?<link>https?://.*\..*|localhost:.*/.*)"}, raw)
    link = 
      case match do
        %{"link" => l} -> l
        _ -> ""
      end
    link
  end

  def extract_text(phtml) do
    Floki.find(phtml, ".pjgm-postcontent")
    |> hd()
    |> Floki.find("p")
    |> Floki.filter_out("a")
    |> Floki.raw_html()
  end

  def pmap(collection, function) do
    collection
      |> Enum.map(&Task.async(fn -> function.(&1) end))
      |> Enum.map(&Task.await(&1))
  end

  def print_list(list) do
    if list != [] do
      [head | tail] = list
      IO.puts(Floki.raw_html(head))
      if tail != [] do
        print_list(tail)
      end
    else
      IO.puts("empty")
    end
  end

  def slice_tail(text) do
    String.slice(text, -3000..String.length(text))
  end

  def slice_head(text) do
    String.slice(text, 0..300) <> "\n\n"
  end
end
