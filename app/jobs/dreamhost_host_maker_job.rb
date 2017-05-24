class DreamhostHostMakerJob < ApplicationJob
  include SlackNotification
  queue_as :default

  after_perform do |job|
    user_info = job.arguments
    DreamhostUserGrantorJob.perform_later(user_info[0],user_info[1],user_info[2])
  end

  def perform(domain_name, username, email)
    browser = Watir::Browser.new :phantomjs
    browser.driver.manage.window.resize_to(1124,850)
    browser.goto('https://panel.dreamhost.com/')

    browser.input(id: 'username').send_keys(ENV['DREAMHOST_USERNAME'])
    browser.input(id: 'password').send_keys(ENV['DREAMHOST_PASSWORD'])
    browser.button.click
    puts "Logged in!"
    # END

    # ===== NEW USER VARIABLES
    # domain_name = user.domain_name
    # username = user.username
    # email = user.valid_email
    # ===== NAVIGATION
    browser.li(id: 'treenav_tab_domain').button.click
    browser.li(id: 'treenav_subtab_domain_manage').a.click
    browser.a(href: '?tree=domain.manage&current_step=Index&next_step=ShowAddhttp&domain=').click
    # END

    # ===== FILL OUT NEW HOSTING FORM
    browser.input(id: 'cgi-domain').send_keys(domain_name)  
    browser.input(value: 'notwww').click  
    browser.text_field(name: 'newuser_username').value = username
    browser.input(value: 'Fully host this domain').click                  
  
    sleep 5

    if browser.div(class: 'errorbox').exists? && browser.div(class: 'errorbox').div(class: 'body').text =~ /Your username/
        slack_error_notify(domain_name, username, email, "Username Exists")
    end  

    if browser.div(class: 'successbox').exists? || browser.div(class: 'errorbox').div(class: 'body').text =~ /You can't add that domain: already in our system/
      puts 'The host is sucessfully submitted'
    else
        slack_error_notify(domain_name, username, email, "Domain Exists")
    end
  end
end
