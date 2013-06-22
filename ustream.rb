require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_ustream_data

  search_query = "chris brown"
  words = search_query.split
  search = "http://www.ustream.tv/new/search?q="
  str = ""
  index = 0
  while index < words.count
    if index == 0
      str += words[0]
      index += 1
    else
      str += "%20" + words[index]
      index += 1
    end
  end

  @agent ||= init_agent
  @ret = []
  page = @agent.get (search + str)
  page.search('.item-image').each do |item|
    if item.at('a')[:href].split("/")[1] == "recorded"
      data = {}
      data[:title] = item.at('a')[:title]
      data[:url] = "http://www.ustream.tv/embed/recorded/" + item.at('a')[:href].split("/")[2] + "?v=3&amp;wmode=direct"
      data[:thumb_url] = item.at('a img')[:src] rescue nil
      data[:width] = 480
      data[:height] = 384
      @ret << data
    end
  end
  @ret
end

p get_ustream_data