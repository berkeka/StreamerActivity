require 'httparty'
require 'json'

# GET CONFIG
file = File.read('config.json')
data = JSON.parse(file)

# Base info
base_url = 'https://api.twitch.tv/helix/'
api_key = data['api_key']
username = data['username']
headers = {
  "Client-ID" => api_key
 }

# GET USER INFO
user_response = HTTParty.get(base_url + "users?login=#{username}", headers: headers)
user_data = user_response['data']
user_id = user_data.first['id']


response = HTTParty.get(base_url + "users/follows?from_id=#{user_id}&first=100", headers: headers)

followed_users = response['data']

broadcaster_ids = []
followed_users.each do |user|
  broadcaster_ids <<  user['to_id']
end

p broadcaster_ids.size
