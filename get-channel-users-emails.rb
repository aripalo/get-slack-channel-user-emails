require 'rest-client'
require 'json'

token = ARGV[0]
channel_name = ARGV[1]

# Slack API URLs
slack_api_base_url = "https://slack.com/api"
slack_api_channel_list_method = "/channels.list"
slack_api_channel_info_method = "/channels.info"
slack_api_user_info_method = "/users.info"


# Get all channels
channels_response = RestClient.get "#{slack_api_base_url}#{slack_api_channel_list_method}", {:params => {:token => token}}
channels_body = JSON.parse(channels_response.body)

# Get's wanted channel
channels = channels_body['channels']
channel = channels.at(channels.find_index{|channel| channel['name'] == channel_name})

# Ensure channel found
if channel == nil
  abort("No channel found with name \"#{channel_name}\"")
end

# Array to store all emails
emails = []

# Fetch emails, but only from active users
channel['members'].each do |member|
  user_response = RestClient.get "#{slack_api_base_url}#{slack_api_user_info_method}", {:params => {:token => token, :user => member}}
  user_body = JSON.parse(user_response.body)
  user = user_body['user']
  if user['deleted'] == false
    email = user['profile']['email']
    emails.push(email)
    puts email
  end
end

time = Time.new
filename = "results/user-emails-#{channel_name}-#{time.strftime("%Y-%m-%d %H:%M:%S")}.txt"
File.open(filename, 'w') { |file| file.write(emails.join("\n")) }
puts "Emails written into file: #{filename}"
