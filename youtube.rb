require 'mechanize'

#YOUTUBE VIDEO --> SHARE --> EMBED IFRAME STUFF

#EXAMPLE OF HOW TO EMBED YOUTUBE VIDEOS
#<iframe title="YouTube video player" width="512" height="312" src="http://www.youtube.com/embed/2lcp0uZsY7k" frameborder="0" allowfullscreen></iframe>
#LATER IMPLEMENT SO THAT YOU CAN ADD/SUBSCRIBE FROM NOTIFYME

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_youtube_data email, password
  @agent ||= init_agent
  messages = []
  page = @agent.get 'https://accounts.google.com/ServiceLogin?service=youtube&uilel=3&continue=http%3A%2F%2Fwww.youtube.com%2Fsignin%3Faction_handle_signin%3Dtrue%26feature%3Dsign_in_button%26hl%3Den_US%26next%3D%252F%26nomobiletemp%3D1&hl=en_US&passive=true'

  # log in
  form = page.form
  form['Email'] = email
  form['Passwd'] = password
  page = form.submit form.button

  # get the basic html page
  page = @agent.get 'http://www.youtube.com/feed/subscriptions'
 
  ret = []

  page.search('.feed-item-main').each do |item|
    data = {}
    data[:channel] = item.at('span.feed-item-owner').text.strip
    data[:channel_href] = 'www.youtube.com' + item.at('span.feed-item-owner a')[:href].to_s
    data[:video_title] = item.at('.yt-ui-ellipsis-2').text.strip
    vidhref = item.at('.yt-ui-ellipsis-2')[:href].to_s
    data[:video_href] = 'www.youtube.com/embed/' + vidhref[9..vidhref.length]
    data[:view_count] = item.at('span.view-count').text.strip
    data[:description] = item.at('div.metadata div').text.strip
    ret << data
  end
  ret
end


p get_youtube_data 'email', 'password'