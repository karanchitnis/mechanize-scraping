require 'mechanize'

#TODO PAGING

def init_agent
  agent = Mechanize.new{|a| a.history.max_size = 10}
  agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  agent
end

def get_github_data email, password
  @agent ||= init_agent
  messages = []
  page = @agent.get 'https://github.com/login'

  # log in
  form = page.form
  form['login'] = email
  form['password'] = password
  page = form.submit form.button

  # get the basic html page
  page = @agent.get 'https://github.com/'
  

  # get all repos in user
  username = page.search('div div div span span').text.strip
  public_repos = page.search('.repos li a span')
  public_repo_name = public_repos.text.split(username)
  #puts public_repo_name
  public_repo_urls = []
  public_repo_commit_urls = []
  tot_repos = []
  public_repo_name.each do |elem|
    if elem.length > 0
      public_repo_urls << 'https://github.com/' + username + '/' + elem 
      public_repo_commit_urls << 'https://github.com/' + username + '/' + elem + '/commits'
      tot_repos << elem
    end
  end
  
  data = {}
  repo_info = []
  arr_image = []
  arr_message = []
  arr_message_href = []
  arr_author = []
  arr_author_href = []
  arr_time = []

  public_repo_commit_urls.each do |url|
    page = @agent.get url
    page.search('div.commit-meta').each do |item| 
      arr_image << page.image_with(:class => "gravatar").fetch 
      
      #arr_author << item.at('span.author-name a').text.strip
      #arr_author_href << 'https://github.com/' + item.at('span.author-name a')[:href]
        #var = data[:hi].to_s
        #var += "hi"
        #data[:hi] = var 
    end
    index = 0
    page.search('ol.commit-group a').each do |item|
      if index % 4 == 0
        arr_message << item.text.strip
        arr_message_href << 'https://github.com' + item[:href]
      end
      index += 1
    end 
    page.search('div.authorship').each do |item|
      arr_author << item.at('a').text.strip
      arr_author_href << 'https://github.com' + item.at('a')[:href].to_s
    end 
    
    data[:images] = arr_image
    data[:message] = arr_message
    data[:message_href] = arr_message_href
    data[:arr_author] = arr_author
    data[:arr_author_href] = arr_author_href
    repo_info << data

  end
  repo_info
  tot_repos

end

p get_github_data 'email', 'password'