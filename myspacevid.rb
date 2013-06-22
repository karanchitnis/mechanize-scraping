require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_myspace_data

  search_query = "chris brown"
  words = search_query.split
  search = "http://www.myspace.com/search/Videos?q="
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
  str += "&sl=tp"

  @agent ||= init_agent
  page = @agent.get (search + str)
  @ret = []
  page.search('.rowPos').each do |item|
    data = {}
    data[:title] = item.at('a img')[:alt]
    data[:url] = "http://mediaservices.myspace.com/services/media/embed.aspx/m=" + item.at('a')[:href].split("/").last + ",t=1,mt=video"
    data[:thumb_url] = item.at('a img')[:src]
    data[:width] = 425
    data[:height] = 360
    @ret << data
  end
  @ret

end

p get_myspace_data