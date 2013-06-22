require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_veoh_data

  search_query = "chris brown"
  words = search_query.split
  search = "http://www.veoh.com/find/?query="
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
  count = 0
  thumb = "#thumb_browse_"
  page.search('#browseList li .thumbWrapper').each do |item|
    data = {}
    id = thumb + count.to_s
    data[:title] = item.at(id)[:title]
    data[:url] = "http://www.veoh.com/static/swf/veoh/SPL.swf?version=AFrontend.5.7.0.1396&permalinkId=" + item.at(id)[:href].split("/").last + "&player=videodetailsembedded&videoAutoPlay=0&id=anonymous"
    data[:thumb_url] = item.at(id + ' img')[:src] rescue nil
    data[:width] = 410
    data[:height] = 341
    @ret << data
    count += 1
  end
  @ret
end

p get_veoh_data