require 'rss'

namespace :podcasts do
  desc 'Anchor.fm から Podcast データ情報を取得して登録'
  task upsert: :environment do
    user_id = '626746926'
    logger  = ActiveSupport::Logger.new('log/podcasts.log')
    console = ActiveSupport::Logger.new(STDOUT)
    logger  = ActiveSupport::BroadcastLogger.new(logger, console)

    logger.info('==== START podcasts:upsert ====')

    ANCHOR_FM_RSS = Rails.env.test? ?
      'anchorfm_sample.rss' :
      'https://anchor.fm/s/54d501e8/podcast/rss'
    rss = RSS::Parser.parse(ANCHOR_FM_RSS, false)

    if rss.items.length.zero?
      logger.info('No track exists. Maybe failed to set RSS URL?')
      exit
    end

    Podcast.transaction do
      rss.items.each_with_index do |item, index|
        episode_id = item.title.split('-').first.to_i
        raise StandardError.new("ID 取得に失敗しました。(Title: #{item.title})") if episode_id.zero?

        episode = Podcast.find_by(id: episode_id) || Podcast.new(id: episode_id)
        episode.new_record? ?
          logger.info("Creating: #{item.title   }") :
          logger.info("Updating: #{episode.title}")

        params = {
          title:          item.title,
          description:    item.description,
          content_size:   item.enclosure.length,
          duration:       item.itunes_duration.content,
          permalink:      item.link.split('/').last,
          permalink_url:  item.link,
          enclosure_url:  item.enclosure.url,
          published_date: item.pubDate.to_date,
        }
        params[:id] = episode_id if episode.new_record?

        episode.update!(params)
      end
    end

    logger.info('==== END podcasts:upsert ====')
    true
  end
end
