#LOCATION IN TRACK PACKAGES SHIFTING EVERYTHING DOWN BY 1 ELEMENT

require 'mechanize'

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end


def get_amazon_data email, password
  @agent ||= init_agent
  ret = []

  # log in
  page = @agent.get 'https://www.amazon.com/ap/signin?_encoding=UTF8&openid.assoc_handle=usflex&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.com%2Fgp%2Fyourstore%2Fhome%3Fie%3DUTF8%26ref_%3Dgno_signin'
  form = page.form
  form['email'] = email
  form['password'] = password
  
  page = form.submit
  page = @agent.get 'https://www.amazon.com/gp/css/order-history' 
  #puts page.links

  ret = []

  page.search('div.ship-contain').each do |item|
    data = {}
    data[:delivery_date] = item.at('div.deliv-text').text.strip
    data[:item] = item.at('span.item-title').text.strip
    track_url = 'https://www.amazon.com' + item.at('div.action a')[:href] rescue nil
    track_page = @agent.get track_url
    data[:status] = track_page.search('table.trackTable td span')[0].text.strip
    data[:signed_for_by] = track_page.search('table.trackTable td span')[1].text.strip
    data[:ship_carrier] = track_page.search('table.trackTable td span')[2].text.strip
    data[:tracking_id] = track_page.search('table.trackTable td')[7].text.strip
    data[:ship_carrier] = track_page.search('table.trackTable td')[9].text.strip
    ret << data
  end
  ret

end
 
p get_amazon_data 'email', 'password'