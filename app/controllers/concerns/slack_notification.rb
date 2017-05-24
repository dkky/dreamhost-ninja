require 'unirest'
module SlackNotification
  extend ActiveSupport::Concern

  def slack_error_notify(domain_name, username, email, error)
    Unirest.post(ENV['SLACK_WEBHOOK'],
                 parameters: {
                      "text": "Error in dreamhost-ninja",
                      "username": "dreamhost-ninja",
                      "icon_emoji": ":japanese_goblin:",
                      "attachments": [
                        {
                            "title": "*Details of registration",
                            "text": "*domain_name*: #{domain_name} \n *username*: #{username} \n *email*: #{email}",
                            "pretext": "*Message:* #{error}"
                            "mrkdwn_in": [
                                "text",
                                "pretext"
                            ]
                        }
                      ]
                 }.to_json
                )
  end
end