require "crawler/version"
require 'open-uri'
require 'nokogiri'
require 'pry'

module Crawler
  class HTML
    attr_accessor :site, :site_hostname, :visited

    def initialize(site)
      @site = site
      @site_hostname = URI(site).hostname
      @visited = []
    end

    def dump_links
      crawl(self.site)
    end

    def crawl(url, prev_url:nil)
      uri = URI(url)
      self.visited.push(url)
      links = Crawler::HTML.get_page_links(url)
      return unless links

      links.each do |link|
        go_to_url = get_fully_qualified_url(link)
        next unless go_to_url

        unless self.visited.include?(go_to_url)
          if prev_url.nil?
            p go_to_url
            crawl(go_to_url)
          elsif !prev_url.nil? and go_to_url == prev_url
            p go_to_url
            crawl(go_to_url, prev_url: url)
          end
        end
      end
    end

    def self.get_page_links(url)
      begin
        page = Nokogiri::HTML(open(url))
      rescue Exception => e
        return
      end
      page.css('a').map { |link| link.attribute('href') ? link.attribute('href').value : nil }.compact
    end

    def get_fully_qualified_url(link)
      link_hostname = URI(link).hostname
      if link_hostname.nil?
        URI.join(self.site, link).to_s
      elsif link_hostname == self.site_hostname
        link
      end
    end
  end
end
