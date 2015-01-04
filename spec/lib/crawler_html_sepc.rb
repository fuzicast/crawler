require 'rspec'
require 'crawler'
require 'pry'

describe Crawler::HTML do
  let(:mock_html) { '<a href="/hello.html">hello</a><img src="/cat.jpg"/><script src="/script.js"></script><a target="_blank">Blank</a>' }
  before :each do
    @crawler = Crawler::HTML.new('http://www.google.com')
  end

  it "should be able to get_page_links" do
    allow(Crawler::HTML).to receive(:open) { mock_html }
    page_object = Crawler::HTML.get_page_object('http://www.google.com')
    links = Crawler::HTML.get_page_links(page_object)
    expect(links.length).to eql 1
    expect(links[0]).to eql '/hello.html'
  end

  it "should be able to get_page_images" do
    allow(Crawler::HTML).to receive(:open) { mock_html }
    page_object = Crawler::HTML.get_page_object('http://www.google.com')
    links = Crawler::HTML.get_page_images(page_object)
    expect(links.length).to eql 1
    expect(links[0]).to eql '/cat.jpg'
  end

  it "should be able to get_page_js" do
    allow(Crawler::HTML).to receive(:open) { mock_html }
    page_object = Crawler::HTML.get_page_object('http://www.google.com')
    links = Crawler::HTML.get_page_js(page_object)
    expect(links.length).to eql 1
    expect(links[0]).to eql '/script.js'
  end

  it "should be able to get_fully_qualified_url" do
    link = @crawler.get_fully_qualified_url('/hello.html')
    expect(link).to eql 'http://www.google.com/hello.html'

    link = @crawler.get_fully_qualified_url('http://www.notgoogle.com/hello.html')
    expect(link).to be_nil

    link = @crawler.get_fully_qualified_url('http://www.google.com/bye.html')
    expect(link).to eql 'http://www.google.com/bye.html'
  end

  it "should be able to crawl a site" do
    allow(Crawler::HTML).to receive(:open) { mock_html }
    expected_site_map = { "http://www.google.com" =>
      {
        :images => ["/cat.jpg"],
        :js => ["/script.js"],
        :links => [
          { "http://www.google.com/hello.html" =>
            {
              :images => ["/cat.jpg"],
              :js => ["/script.js"],
              :links=>[]
            }
          }
        ]
      }
    }
    site_map = @crawler.generate_site_map
    expect(site_map).to eql expected_site_map
    expect(@crawler.visited).to eql ['http://www.google.com', 'http://www.google.com/hello.html']
  end

  it "should hold the correct state for crawler" do
    expect(@crawler.site).to eql 'http://www.google.com'
    expect(@crawler.site_hostname).to eql 'www.google.com'
    expect(@crawler.visited.length).to eql 0
  end
end
