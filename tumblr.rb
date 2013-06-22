require 'mechanize'
require 'chronic'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_tumblr email, password
  #puts "Logging in to tumblr..."
  @agent ||= init_agent
  page = @agent.get 'https://www.tumblr.com/login'
  # log in
  form = page.forms.find{|f| f.field_with(:name => 'user[email]')}

  form.action = 'https://www.tumblr.com/login'
  form['user[email]'] = email
  form['user[password]'] = password
  page = form.submit form.button
  page = @agent.get 'http://www.tumblr.com/dashboard'

  #puts page.body[/notifytester/] ? 'Success' : 'Failed'
  ret = []
  page.search('.with_permalink').each do |item|
    data = {}
    data[:user] = item.at('.post_info a').text
    #data[:user_href] =  item.at('.post_info a')[:href]
    data[:user_href] = item.search('a.post_avatar').map{|x| x[:style][/'(.*?)'/, 1]}
    data[:reblog] =  item.at('.reblog_count span').text
    data[:image_href] = item.at('.post_info span a')[:href].to_s rescue nil
    #data[:user_image] = item.at('.image')[:src].to_s
    #puts item.search('div.video + input').map{|x| x[:value][/src="(.*?)"/, 1]} rescue nil
    data[:video] = item.search('div.video + input').map{|x| x[:value][/src="(.*?)"/, 1]}
    data[:caption] =  item.at('p').text.strip
    ret << data
  end
  puts ret

# if page.search('div.video + input').map{|x| x[:value][/src="(.*?)"/, 1]}
#  puts 'hi'
# end
 
end

get_tumblr 'email', 'password'