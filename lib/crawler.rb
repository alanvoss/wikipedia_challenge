require 'curb'
require 'set'
require 'pry'

class WikipediaCrawler

  def initialize(start_page, options = {})
    @start_page = start_page
    @options = options
    @seen_pages = Set.new
  end

  def execute(url = @start_page)
    name = ""
    while @seen_pages.add?(url) || is_philospher?(name)
      puts "URL: #{url}, NAME: #{name}"
      begin
        content = get_page(url)
        url, name = find_link(content)
      rescue
        return "cycle"
      end
    end

    is_philospher?(name) ? "philosopher" : "cycle"
  end

  private

  def is_philospher?(name)
    name.downcase.include?("philosophy")
  end

  def get_page(url)
    Curl.get(url).body
  end

  def find_link(html)
    link = html.match(/<a href *= *"([^"]+)"[^>]*>([^<]+)/)
    url = link[1]
    url.sub!(%r{^(?=/)}, "https://en.wikipedia.org")
    name = link[2]
    [url, name]
  end
end


puts WikipediaCrawler.new("https://en.wikipedia.org/wiki/Mike_Tyson").execute
