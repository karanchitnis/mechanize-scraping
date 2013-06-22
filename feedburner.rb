require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_feedburner_data email, password, website, recovery_email = 'karanchitnis92@gmail.com'
  @agent ||= init_agent
  messages = []
  page = @agent.get 'https://accounts.google.com/ServiceLogin?service=feedburner&continue=http%3A%2F%2Ffeedburner.google.com%2Ffb%2Fa%2Fmyfeeds'

  # log in
  form = page.form
  form['Email'] = email
  form['Passwd'] = password
  page = form.submit form.button

  # if there's a challenge
  if form = page.form_with(:action => 'LoginVerification')
    form['emailAnswer'] = recovery_email
    page = form.submit form.button
  end

  # get the basic html page
  page = @agent.get 'http://feedburner.google.com/fb/a/myfeeds'

  # still need to click on button
  feed_form = page.form_with(:name => 'createFeedActionForm')
  feed_form['sourceUrl'] = website
  page = feed_form.submit feed_form.button

  # select default, keep submitting up to 5 times
  limit = 5
  while (form = page.form_with(:name => 'createFeedActionForm')) && (limit > 0)
    return 'Invalid Feed' if page.body[/We could not find a valid feed at that address/i]
    limit -= 1
    page = form.submit form.button
    break if page.body[/congrats/i]
  end

  page.at('p#feedAddress a')[:href]

end


p get_feedburner_data 'email', 'password', 'website'