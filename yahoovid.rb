require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_yahoo_data

  search_query = "chris brown"
  words = search_query.split
  search = "http://video.search.yahoo.com/search/?ei=UTF-8&fr=screen&q="
  str = ""
  index = 0
  while index < words.count
    if index == 0
      str += words[0]
      index += 1
    else
      str += "+" + words[index]
      index += 1
    end
  end

  @agent ||= init_agent
  page = @agent.get (search + str)
  @ret = []
  page.search('#Catalog1 li').each do |item|
    data = {}
    data[:title] = item.at('.ItemTitle a').text
    data[:url] = item.at('ItemTitle')
    data[:thumb_url] = 'www.metacafe.com' + item.at('img')[:src]
    data[:width] = 440
    data[:height] = 248
    @ret << data
  end
  @ret

end

p get_yahoo_data