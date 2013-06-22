require 'mechanize'
require 'nokogiri'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_messages
  page = @agent.get 'http://www.linkedin.com/inbox/messages/received'
  ret = []

  page.search('.message-item').each do |item|
    data = {}
    data[:name] = item.at('.photo').text.strip rescue nil
    data[:title_url] = URI.join('http://www.linkedin.com/', item.at('span.miniprofile-container a')[:href]).to_s rescue nil
    data[:desc] = item.at('.detail-link').text.strip rescue nil
    data[:desc_url] = URI.join('http://www.linkedin.com/', item.at('.detail-link')[:href]).to_s rescue nil
    data[:photo] = item.at('.photo')[:src].to_s rescue nil
    data[:date] = item.at('.date').text.strip rescue nil
    if item.at('.inbox-item') == nil
      data[:unread] = false
    else
      data[:unread] = true
    end
    ret << data
  end
  ret
end


def get_invitations
  page = @agent.get 'http://www.linkedin.com/inbox/invitations/pending?trk=hb-invitations-hdr-inv-v2'
  ret = []

  page.search('.invitation-item').each do |item|
    data = {}
    data[:name] = item.at('span.miniprofile-container a').text.strip rescue nil
    data[:title_url] = URI.join('http://www.linkedin.com/', item.at('span.miniprofile-container a')[:href]).to_s rescue nil
    data[:desc] = item.at('span.headline').text.strip rescue nil
    data[:photo] = item.at('.photo')[:src].to_s rescue nil
    data[:date] = item.at('.date').text.strip rescue nil
    ret << data rescue nil
  end
  ret
end


def get_linkedin_data email, password
  @agent ||= init_agent
  ret = []

  # log in
  page = @agent.get 'http://www.linkedin.com/'
  form = page.form
  form['session_key'] = email
  form['session_password'] = password
  
  page = form.submit
  #page = @agent.get 'http://www.linkedin.com/inbox/messages/received'
  messages = get_messages
  invitations = get_invitations

  {:messages => messages, :invitations => invitations}

end
 
puts get_linkedin_data 'email', 'password'