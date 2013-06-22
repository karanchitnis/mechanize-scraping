require 'mechanize'
require 'json'
require 'jsonpath'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def scrape_friend_request a
  data = {}
  data[:name] = a.text
  data[:url] = URI.join('http://www.facebook.com/', a[:href]).to_s
  data[:info] = a.parent.at('~ .requestInfoContainer').text rescue nil
  data
end

def scrape_notification li
  data = {}
  data[:user] = li.at('div.info a').text
  data[:description] = li.at('div.info').text
  data[:strings] = li.search('div.info a')[0..-2].map do |a|
    "#{a.text} - #{URI.join('http://www.facebook.com/', a[:href]).to_s}"
  end
  data[:url] = URI.join('http://www.facebook.com/', li.at('div.info a')[:href]).to_s
  data[:time] = Time.at li['data-notiftime'].to_i
  data
end

def get_messages
  ret = []
  page = @agent.get 'http://www.facebook.com/messages/'
  s = page.search('script[text()*="threads"]').find{|s| JSON.parse(s.text[/{.*}/]) rescue nil}
  raise 'no messages!' unless s
  json = s.text[/{.*}/];
  threads = JsonPath.new('$..threads').on(json).flatten
  participants = JsonPath.new('$..participants').on(json).flatten
  threads.each do |thread|
    data = {}
    data[:text] = thread['snippet']
    data[:time] = Time.at thread['timestamp']
    pid = thread['snippet_sender'][/\d+/].to_i
    participant = participants.find{|p| p['fbid'] == pid}
    data[:sender] = participant['name']
    data[:sender_image] = participant['image_src']
    data[:sender_url] = participant['href']
    ret << data
  end
  ret

end

def get_notifications
  ret = []
  page = @agent.get 'http://www.facebook.com/notifications'
  page.search('li.notification').each do |li|
    ret << scrape_notification(li)
  end
  ret
end

def get_friend_requests
  ret = []
  page = @agent.get 'http://www.facebook.com/friends/requests/'
  page.search('h2 a').each do |a|
    ret << scrape_friend_request(a)
  end
  ret
end

def get_facebook_data email, password
  @agent ||= init_agent

  # log in
  page = @agent.get 'http://www.facebook.com/'
  form = page.form
  form['email'] = email
  form['pass'] = password
  page = form.submit

  # get data
  messages = get_messages
  notifications = get_notifications
  friend_requests = get_friend_requests

  {:notifications => notifications, :messages => messages, :friend_requests => friend_requests}
end

puts get_facebook_data 'email', 'password'
