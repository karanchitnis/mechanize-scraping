require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_youtube_data email, password
  @agent ||= init_agent
  messages = []
  page = @agent.get 'https://www.facebook.com/login.php?skip_api_login=1&next=https%3A%2F%2Fwww.facebook.com%2Fdialog%2Foauth%3Fclient_id%3D8744a0ccdce1491c4474dacf75dc2d12%26redirect_uri%3Dhttp%253A%252F%252Fwww.myspace.com%252Ffbocallback%253Fuhp%253Duhp%26scope%3Demail%252Coffline_access%252Cuser_about_me%252Cuser_birthday%252Cuser_likes%252Cpublish_stream%252Cpublish_actions%26display%3Dpopup%26from_login%3D1&cancel_uri=http%3A%2F%2Fwww.myspace.com%2Ffbocallback%3Fuhp%3Duhp&display=popup&api_key=8744a0ccdce1491c4474dacf75dc2d12'

  # log in
  form = page.form
  form['Email'] = email
  form['Passwd'] = password
  page = form.submit form.button

  # get the basic html page
  page = @agent.get 'http://www.myspace.com/home'
  puts page.links
 
  
end

p get_youtube_data 'email', 'password'