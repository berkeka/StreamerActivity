require 'httparty'
require 'json'
require 'gtk3'

class NotificationWindow < Gtk::Window
  WIN_HEIGHT = 100
  WIN_WIDTH = 300
  NOTIFICATION_DURATION = 2

    def initialize(input)
        super

        signal_connect("destroy") {Gtk.main_quit}

        set_decorated(false)
        set_default_size WIN_WIDTH, WIN_HEIGHT
        set_window_position Gtk::WindowPosition::CENTER
        set_border_width 10
        add Gtk::Label.new input

        show_all
    end
end

  window = NotificationWindow.new("Label Message")
  Gtk.main

def checkGameChange(broadcasters, broadcasters2)
  broadcasters2.each do |streamer, game|
    if(broadcasters.key?(streamer))
      if(broadcasters[streamer] != broadcasters2[streamer])
        # Game change
        label = "#{streamer} is now playing #{broadcasters2[streamer]}"
        # HANDLE GUI NOTIFICATION
      end
    else
      # Streamer went live
      label = "#{streamer} went live. Currently playing #{broadcasters2[streamer]}"
      # HANDLE HUI NOTIFICATION
    end
  end
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

broadcasters = { }
broadcasters2 = { }

while true
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
      broadcasters2[stream['user_name']] = game_name
    end
  end

  # FIRST INITIALIZATION OF BROADCASTERS
  if broadcasters.empty?
    broadcasters = broadcasters2
  end

  checkGameChange(broadcasters, broadcasters2)
  broadcasters = broadcasters2
  broadcasters2 = {}


  #puts broadcasters
  sleep 60
end
