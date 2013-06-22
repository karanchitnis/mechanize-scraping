require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #agent.redirection_limit = 500
  #agent.follow_meta_refresh = true
  agent
end

def get_calnet username, password
  #puts "Logging in to calnet..."
  @agent ||= init_agent
  page = @agent.get 'https://auth.berkeley.edu/cas/login?service=https%3A%2F%2Fbspace.berkeley.edu%2Fsakai-login-tool%2Fcontainer&renew=true'
  form = page.form
  form['username'] = username
  form['password'] = password
  @agent.redirect_ok = false
  page = form.submit form.button
  @agent.redirect_ok = true
  #puts page.code == '302' ? 'Success (maybe)' : 'Failed'
  page = @agent.get 'https://bspace.berkeley.edu/portal'
  #puts page.links
  #puts page.search('li.selectedTool').text.strip
  page.search('li').each do |item|
    puts item.at('a').text rescue nil
  end
end

 
puts get_calnet 'email', 'password'

    
