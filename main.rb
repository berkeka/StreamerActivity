require 'httparty'
require 'json'

def checkGameChange(broadcaster_ids)

end

def getGameNames(followed_users, base_url, headers)
  request_string = 'games?'
  followed_users.each do |user|
    request_string += "id=" + user['game_id'] + "&"
  end
  request_string.chomp('&')
  response = HTTParty.get(base_url + request_string, headers: headers)
  response['data']
end

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
live_broadcaster_ids = []

followed_users.each do |user|
  broadcaster_ids <<  user['to_id']
end

request_string = "streams?"

broadcaster_ids.each do |broadcaster|
  request_string += "user_id=#{broadcaster}&"
end

broadcasters = { }

request_string.chomp('&')

followed_users_response = HTTParty.get(base_url + request_string, headers: headers)

game_names = getGameNames(followed_users_response['data'], base_url, headers)

followed_users_response['data'].each do |stream|
  game_name = ""
  if stream['type'] == 'live'
    game_names.each do |game|
      if stream['game_id'] == game['id']
        game_name = game['name']
      end
    end
    broadcasters[stream['user_name']] = game_name
  end
end

#puts followed_users_response['data']
puts broadcasters

#while true
  # CALL MAIN REQUESTS broadcasters1
  # 2 MIN LATER CALL AGAIN broadcasters2
  # CHECK FOR CHANGED GAMES
#end
