# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://coderdojo.jp"

# Configure search engines to ping (exclude Google as it's deprecated)
SitemapGenerator::Sitemap.ping_search_engines = true
SitemapGenerator::Sitemap.search_engines = {
  'bing' => 'http://www.bing.com/ping?siteMap=%s',
  # Google を非推奨になったため除外: https://developers.google.com/search/blog/2023/06/sitemaps-lastmod-ping
}

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host

  add events_path,      priority: 0.9
  add '/kata',          priority: 0.9
  add partnership_path, priority: 0.8
  add stats_path,       priority: 0.8
  add charter_path,     priority: 0.7

  add podcasts_path,    priority: 0.6
  Podcast.find_each do |episode|
    add podcast_path(episode), lastmod: episode.updated_at, priority: 0.6
  end

  add docs_path,        priority: 0.5
  last_commit_date = Document.first.updated_at
  Document.all.each do |doc|
    add doc.url, lastmod: last_commit_date, priority: 0.5
  end

  add teikan_path,      priority: 0.4
  add privacy_path,     priority: 0.4


  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
