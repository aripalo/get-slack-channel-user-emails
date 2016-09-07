require 'rest-client'
require 'json'

token = ARGV[0]
base_url = "https://slack.com/api"

channel = ARGV[1]

channel_info_method = "/channels.info"


response = RestClient.get "#{base_url}#{channel_info_method}", {:params => {:token => token, :channel => channel}}

body = JSON.parse(response.body)

members = body['channel']['members']
channel_name = body['channel']['name']

user_info_method = "/users.info"

emails = []

members.each do |member|
  #puts member
  user_response = RestClient.get "#{base_url}#{user_info_method}", {:params => {:token => token, :user => member}}
  user_body = JSON.parse(user_response.body)
  #puts user_body.inspect
  user = user_body['user']
  if user['deleted'] == false
    email = user['profile']['email']
    emails.push(email)
    puts email
  end
end

File.open("results/user-emails-#{channel_name}.txt", 'w') { |file| file.write(emails.join("\n")) }
