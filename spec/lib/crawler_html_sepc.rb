require 'rspec'
require 'crawler'
require 'pry'

describe Crawler::HTML do
  let(:mock_html) { '<a href="/hello.html">hello</a><a target="_blank">Blank</a>' }
  before :each do
    @crawler = Crawler::HTML.new('http://www.google.com')
  end

  it "should be able to get_page_links" do
    allow(Crawler::HTML).to receive(:open) { mock_html }
    links = Crawler::HTML.get_page_links('http://www.google.com')
    expect(links.length).to eql 1
    expect(links[0]).to eql '/hello.html'
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
    @crawler.dump_links
    expect(@crawler.visited).to eql ['http://www.google.com', 'http://www.google.com/hello.html']
  end

  it "should hold the correct state for crawler" do
    expect(@crawler.site).to eql 'http://www.google.com'
    expect(@crawler.site_hostname).to eql 'www.google.com'
    expect(@crawler.visited.length).to eql 0
  end
end
