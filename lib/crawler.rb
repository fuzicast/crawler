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

    def generate_site_map
      crawl(self.site)
    end

    def crawl(url, prev_url:nil)
      site_map = {}
      site_map[url] = {}
      uri = URI(url)
      self.visited.push(url)
      page_object = Crawler::HTML.get_page_object(url)
      return unless page_object

      links = Crawler::HTML.get_page_links(page_object)
      images = Crawler::HTML.get_page_images(page_object)
      js = Crawler::HTML.get_page_js(page_object)
      site_map[url][:images] = images
      site_map[url][:js] = js
      site_map[url][:links] = []
      return unless links

      links.each do |link|
        go_to_url = get_fully_qualified_url(link)
        next unless go_to_url

        unless self.visited.include?(go_to_url)
          if prev_url.nil?
            site_map[url][:links].push(crawl(go_to_url))
          elsif !prev_url.nil? and go_to_url == prev_url
            site_map[url][:links].push(crawl(go_to_url, prev_url: url))
          end
        end
      end
      site_map
    end

    def self.get_page_object(url)
      begin
        Nokogiri::HTML(open(url))
      rescue Exception => e
        return
      end
    end

    def self.get_page_links(page_object)
      page_object.css('a').map { |link| link.attribute('href') ? link.attribute('href').value : nil }.compact
    end

    def self.get_page_images(page_object)
      page_object.css('img').map { |link| link.attribute('src') ? link.attribute('src').value : nil }.compact
    end

    def self.get_page_js(page_object)
      page_object.css('script').map { |link| link.attribute('src') ? link.attribute('src').value : nil }.compact
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
