defmodule UnsongScraper do
  @start "https://parahumans.wordpress.com/2011/06/11/1-1/"
  # "https://parahumans.wordpress.com/category/stories-epilogue/interlude-end/"
  @toc "https://parahumans.wordpress.com/table-of-contents/"

  def main do
    # scrape_next(@start, 0)
    scrape_toc(@toc)
  end

  def scrape_toc(link) do
    response = HTTPotion.get(link)
    html_tree = Floki.parse(response.body)
    all_links =
      html_tree
      |> Floki.find(".entry-content")
      |> Floki.find("a")
    ch_links = find_ch_links(Enum.slice(all_links, 0..2))
    ch_texts = Enum.map(ch_links, &scrape_ch/1)
    ch_texts
  end

  def scrape_ch(link) do
    response = HTTPotion.get(link)
    html_tree = Floki.parse(response.body)
    text = extract_text(html_tree)
    text
  end

  def find_ch_links(links_list) do
    links_list_filtered = Enum.filter(links_list, fn x ->
      Regex.match?(~R(https://parahumans.wordpress.com/.*), get_link_url2(x))
    end)
    Enum.map(links_list_filtered, &get_link_url2/1)
  end

  def get_link_url2(html_tree) do
    link =
      html_tree
      |> elem(1)
      |> hd()
      |> elem(1)
    link
  end

  def scrape_next(link, depth) do
    response = HTTPotion.get(link)
    phtml = Floki.parse(response.body)
    text = extract_text(phtml)

    next_chapter = Floki.find(phtml, "a[title=\"Next Chapter\"")
    if next_chapter != [] and depth < 5 do
      next_ch_link = get_link_url(next_chapter)
      next_ch_text = scrape_next(next_ch_link, depth+1)
      text <> next_ch_text
    else
      text
    end
  end

  def extract_text(phtml) do
    Floki.find(phtml, ".entry-content")
    |> hd()
    |> Floki.find("p")
    |> Floki.filter_out("a")
    |> Floki.raw_html()
  end

  def get_link_url(link_phtml) do
    next_ch_link =
      link_phtml
      |> hd()
      |> elem(1)
      |> tl()
      |> hd()
      |> elem(1)
    IO.puts(next_ch_link)
    next_ch_link
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
