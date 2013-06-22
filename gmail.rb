require 'mechanize'
require 'chronic'
#require 'pry'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def scrape_email tr
  data = {}
  data[:from] = tr.at('td[2]').text.strip
  if tr.at('td[3] b')
    data[:subject] = tr.at('td[3] b').text.strip
    data[:excerpt] = tr.at('td[3] b + font').text.gsub(/^ - /, '').strip
    data[:unread] = true
  else
    data[:subject] = tr.at('td[3] font[size]').next.text.strip
    data[:excerpt] = tr.at('td[3] font[size] + font').text.gsub(/^ - /, '').strip
    data[:unread] = false
  end
  data[:time] = Chronic.parse tr.at('td[4]').text.gsub(/[[:space:]]+/, ' ').strip, :context => :past
  data
end

def get_gmail_messages email, password
  @agent ||= init_agent
  messages = []
  page = @agent.get 'https://www.gmail.com/'

  # log in
  form = page.form
  form['Email'] = email
  form['Passwd'] = password
  page = form.submit form.button

  # get the basic html page
  raise 'Invalid login!' unless basic_link = page.link_with(:text => /basic HTML view/)
  page = basic_link.click

  # scrape each email
  page.search('table.th > tr').each do |tr|
    puts (messages << scrape_email(tr))
  end

  # do page 2
  if next_link = page.link_with(:text => /Older/)
    page = next_link.click
    page.search('table.th > tr').each do |tr|
      puts (messages << scrape_email(tr))
    end
  end

  messages
end

get_gmail_messages 'email', 'password'
