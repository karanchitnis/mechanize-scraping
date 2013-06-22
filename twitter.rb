require 'mechanize'
require 'chronic'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def scrape_twitter_interaction li
  # IF FROM HAS MORE THAN 1 ELEMENT, ADD A COMMA BETWEEN NAMES AND FOLLOWED YOU
  # CANNOT SCROLL DOWN FOR MORE NOTIFICATIONS (DYNAMIC CONTENT) LIKE QUORA
  # DONT KNOW HOW TO STORE MORE THAN ONE HANDLE/USERNAME

  data = {}
  data[:from] = li.search('strong').map &:text

  data[:text] = li.at('div.stream-item-activity-line a').next.text.strip rescue nil
  if data[:text] == nil
    data[:text] = li.at('p.js-tweet-text').text.strip
  end
  data[:handle] = li.at('span.username').text.strip rescue nil
  if data[:handle] == nil
    data[:handle] = li.at('div.stream-item-activity-header a')[:href].to_s
  end
  if data[:handle].to_s[0] == '@'
    data[:handle].to_s[0] = '/'
  end
  data[:href] = ('https://twitter.com' + data[:handle].to_s)
  data[:pictures] = li.search('a[text()^="pic."]').map{|x| x[:href]}
  data[:time] = Time.at li.at('span._timestamp')['data-time'].to_i
  data

  
  #puts activity
  
end

def get_twitter_interactions email, password
  @agent ||= init_agent
  interactions = []
  page = @agent.get 'https://twitter.com/'

  # log in
  form = page.forms[2]
  form['session[username_or_email]'] = email
  form['session[password]'] = password

  page = form.submit form.button

  page = @agent.get 'https://twitter.com/i/connect'

  page.search('ol.stream-items > li').each do |li|
    interactions << scrape_twitter_interaction(li)
  end

  interactions
end

p get_twitter_interactions 'email', 'password'
