class DreamhostUserGrantorJob < ApplicationJob
  include SlackNotification
  queue_as :default

  def perform(domain_name, username, email)
    browser = Watir::Browser.new :phantomjs
    browser.driver.manage.window.resize_to(1124,850)
    browser.goto('https://panel.dreamhost.com/')
    browser.input(id: 'username').send_keys(ENV['DREAMHOST_USERNAME'])
    browser.input(id: 'password').send_keys(ENV['DREAMHOST_PASSWORD'])
    browser.button.click
    puts "Logged in!"
     # ===== NAVIGATION 2 =======
    browser.li(id: 'treenav_tab_users').button.click
    browser.li(id: 'treenav_subtab_users_access').a.click
    browser.a(href: '?tree=users.access&current_step=Index&next_step=ShowAdd').click
    # END

    # ===== FILL OUT & ADD PRIVILEGES
    browser.input(name: 'email').send_keys(email)
    browser.input(name: 'name').send_keys(domain_name)
    browser.input(name: "domain_#{domain_name}").click


    # ----- The text of the checkbox you want to select
    checkbox_div = browser.divs(:class => 'radiotext')[3]

    # ----- Get the checkbox that has the specified text immediately after it
    checkbox = checkbox_div.checkbox(:xpath => "./input            
        [following-sibling::text()
            [
                position() = 1 and
                normalize-space(.) = '#{username}'
            ]
        ]")
    checkbox.click
    browser.input(id:"SI_4847623").click
    browser.input(value: 'Set Privileges').click
    if browser.div(class: 'error').exists?
        slack_error_notify(domain_name, username, email, "Set Privileges")
    end
    # END ==========================

     #==== NAVIGATION 3 ========
    # browser.li(id: 'treenav_tab_users').button.click
    browser.li(id: 'treenav_subtab_users_access').a.click
    browser.tables.find{|table| puts "user privilege is granted" if table.td(:text=> username).exists?}
  end
end
