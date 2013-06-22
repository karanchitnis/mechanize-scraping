require 'mechanize'
require 'chronic'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_notifications
  page = @agent.get 'https://www.quora.com/notifications'
  ret = []
  page.search('.unseen').each do |item|
    data = {}

    if item.at('span a').text == "Follow"
      data[:name] = item.at('a.user').text.strip rescue nil
      if data[:name] == nil
        user = item.at('div.notification').text.strip
        data[:name] = user[7..user.length-28]
        data[:href] = 'http://www.quora.com' + item.at('div.notification a')[:href].to_s
      end
    else
      data[:name] = item.at('span a').text.strip 
      notif = item.at('div.notification_text').text.strip
      data[:tot_notif] = notif
      data[:href] = 'http://www.quora.com' + item.at('span a')[:href].to_s
      notif = notif.split("question")[1]
      str = ""
      index = 0
      notif.split(" ").each do |x|
        index += 1
        str += x
        if index != notif.length
          str += "-"
        end
      end
      str = str[0..str.length-2]
      data[:href2] = 'http://www.quora.com/' + str[0..-28]
    end
    ret << data 
  end
  ret
end

def get_inbox
  page2 = @agent.get 'https://www.quora.com/inbox'
  ret = []
  page2.search('.w3').each do |item|
    data = {}
    data[:name] = item.at('.user').text.strip
    data[:href] = 'http://www.quora.com' + item.at('.user')[:href].to_s
    data[:message] = item.at('.thread_link').text.strip
    data[:href2] = 'http://www.quora.com' + item.at('.thread_link')[:href].to_s
    ret << data
  end
  ret
end


def get_quora email, password
  #puts "Logging in to quora..."
  @agent ||= init_agent
  messages = []
  page = @agent.get 'https://www.quora.com/'

  # log in
  formkey = page.body[/formkey: "(.*)"/, 1]
  hmac = page.body[/LoggedOutHomeHeaderInlineLogin.*?hmac:(\w+)/, 1]
  window_id = page.body[/windowId = "(.*)"/, 1]

  vars = {
  'json' => '{"args":[],"kwargs":{"email":"' + email + '","password":"' + password + '","passwordless":1}}',
  'formkey' => formkey,
  'window_id' => window_id,
  '_lm_transaction_id' => '0.7020962811075151', # ?????
  '_lm_window_id' => window_id,
  '__vcon_json' => '["hmac","' + hmac + '"]',
  '__vcon_method' => 'do_login',
  'js_init' => '{}'
  }

  @agent.post 'https://www.quora.com/webnode2/server_call_POST', vars, {'Content-Type' => 'application/x-www-form-urlencoded'}
  #page = @agent.get 'https://www.quora.com/notifications'

  #CANNOT GET DYNAMIC TIME
  #CANNOT SCROLL DOWN, BOTH BECAUSE MECHANIZE CANNOT GET DYNAMIC CONTENT
  #puts page.body[/Larry Johnson/] ? 'Success' : 'Failed'

  notifications = get_notifications
  inbox = get_inbox

  
  #puts ret

  {:notifications => notifications, :inbox => inbox}

end

p get_quora 'email', 'password'