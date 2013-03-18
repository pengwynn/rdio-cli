require 'gli'
require 'yaml'
require 'launchy'

require 'api'
require 'rdio/version'
require 'rdio/desktop_bridge'
require 'highline/import'

module Rdio
  extend GLI::App

  program_desc 'Simple CLI for Rdio'

  version Rdio::VERSION

  def self.bridge
    @bridge ||= Rdio::DesktopBridge.new
  end

  def self.api
    token = @access_token ? [@access_token, @access_secret] : nil
    @api = Api.new \
      [@consumer_key, @consumer_secret],
      token
  end

  def self.authorize_api
    url = api.begin_authentication('oob')
    ask "Copy the four digit code from your browser. [ENTER] to continue. "
    Launchy.open url
    code = ask 'Code: '
    @access_token, @access_secret = @api.complete_authentication(code)

    write_config

    say "You're all set. see `rdio help` for usage"
  end

  def self.lyrics_for(artist, title)
    uri = URI('http://makeitpersonal.co/lyrics')
    params = { :artist => artist, :title => title }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    return res.body
  end

  def self.shows_for(artist, count)
    uri = URI('http://ws.audioscrobbler.com/2.0')
    params = { :method => 'artist.getEvents', :artist => artist, :limit => count, :format => 'json', :autocorrect => 1, :api_key => '3c3e4b39c2aedcac5d745c70a898ee76' }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    json = JSON.parse(res.body)
    return "Sorry, I’ve never heard of #{artist}" if json['error'] == 6

    events = json['events']['event']
    events = [events] if events.is_a?(Hash)
    return "No upcoming events for #{artist}" if !events

    corrected_artist_name = json['events']['@attr']['artist']

    cities = []
    countries = []
    events.each do |event|
      cities << event['venue']['location']['city']
      countries << event['venue']['location']['country']
    end

    longest_city = cities.inject { |a, b| a.length > b.length ? a : b }
    longest_country = countries.inject { |a, b| a.length > b.length ? a : b }

    events.map! do |event|
      location = event['venue']['location']

      city = location['city']
      city_spaces = (0..longest_city.length - city.length).map{' '}.join('')

      country = location['country']
      country_spaces = (0..longest_country.length - country.length).map{' '}.join('')

      "#{city}#{city_spaces} #{country}#{country_spaces} #{event['startDate']} #{event['startTime']}"
    end

    "Here are #{count} upcoming events for #{corrected_artist_name}\n#{events.join("\n")}\n"
  end

  def self.rdio_config
    {
     :consumer_key    => @consumer_key,
     :consumer_secret => @consumer_secret,
     :access_token    => @access_token,
     :access_secret   => @access_secret
    }
  end

  def self.write_config
    p = File.join(File.expand_path(ENV['HOME']), '.rdio')
    File.open(p, 'w' ) do |out|
      YAML.dump rdio_config, out
    end
  end

  def self.current_user
    @current_user ||= api.call('currentUser', :extras => 'lastSongPlayed')['result']
  end

  def self.current_track_key
    data = api.call 'getObjectFromUrl', { :url => bridge.current_url }

    data['result']['key']
  end

  def self.current_album_track_keys
    current_album_url = current_user['lastSongPlayed']['albumUrl']
    data = api.call 'getObjectFromUrl', { :url => current_album_url }

    data['result']['trackKeys']
  end

  def self.add_to_collection(tracks)
    tracks = Array(tracks)

    api.call 'addToCollection', { :keys => tracks.join(',') }
  end

  config_file '.rdio'

  desc 'Rdio API consumer key'
  flag :consumer_key, :mask => true
  desc 'Rdio API consumer secret'
  flag :consumer_secret, :mask => true
  desc 'Rdio API access token'
  flag :access_token, :mask => true
  desc 'Rdio API access secret'
  flag :access_secret, :mask => true

  skips_pre
  desc 'Plays the current track'
  command :play do |c|
    c.action do |global_options,options,args|
      bridge.play
    end
  end

  skips_pre
  desc 'Pause the player'
  command :pause do |c|
    c.action do |global_options,options,args|
      bridge.pause
    end
  end

  skips_pre
  desc 'Toggle playback'
  command :toggle do |c|
    c.action do |global_options,options,args|
      bridge.toggle
    end
  end

  skips_pre
  desc 'Display the current track info'
  long_desc %(
    Display current track, artist, and album info. Pass
    format string for custom output using
    %{track}, %{artist}, and %{album} placeholders.
  )
  arg_name 'format'
  command :current do |c|
    c.action do |global_options,options,args|
      say bridge.now_playing(args.first)
    end
  end

  skips_pre
  desc 'Skip to next track'
  command :next do |c|
    c.action do |global_options,options,args|
      bridge.next_track
    end
  end

  skips_pre
  desc 'Play previous track'
  command :previous, :prev do |c|
    c.action do |global_options,options,args|
      bridge.previous_track
    end
  end

  skips_pre
  desc 'Open the current track in Rdio player'
  command :browse do |c|
    c.action do |global_options,options,args|
      protocol = args.first == 'app' ? 'rdio' : 'http'
      exec "open '#{bridge.current_url protocol}'"
    end
  end

  skips_pre
  desc 'Set volume for player'
  arg_name 'level'
  command :volume, :vol do |c|
    c.action do |global_options,options,args|
      level = args.shift.to_i
      bridge.set_volume level
    end
  end

  skips_pre
  desc 'Mute the Rdio player'
  command :mute do |c|
    c.action do |global_options,options,args|
      brdige.set_volume 0
    end
  end

  skips_pre
  desc 'Get a shareable link for the current track'
  command :link do |c|
    c.action do |global_options,options,args|
      say bridge.current_url
    end
  end

  skips_pre
  desc "Get CLI and application version info"
  command :version, :v do |c|
    c.action do |global_options,options,args|
      say "rdio-cli #{Rdio::VERSION} / Rdio #{apple_script('get version of application "Rdio"')}"
    end
  end

  skips_pre
  desc "Quit Rdio"
  command :quit, :q do |c|
    c.action do |global_options,options,args|
      bridge.quit
    end
  end

  skips_pre
  desc "Authorize Rdio account"
  command :authorize, :auth do |c|
    c.action do |global_options,options,args|
      require 'highline/import'
      say "To access your Rdio account, you'll need to get some API keys. "
      say "See http://developer.rdio.com for details. "
      @consumer_key = ask 'Enter your Rdio API key: '
      @consumer_secret = ask 'Enter your Rdio API secret: '

      if @consumer_key && @consumer_secret
        authorize_api
      end
    end
  end

  skips_pre
  desc 'Show lyrics for a track'
  command :lyrics do |c|
    c.flag :artist
    c.flag :title
    c.action do |global_options,options,args|
      artist = options[:artist] || bridge.current_artist
      title = options[:title] || bridge.current_track
      say lyrics_for(artist, title)
    end
  end

  skips_pre
  desc 'Show upcoming events for an artist'
  command :shows do |c|
    c.flag :artist
    c.flag :count, :default_value => 10
    c.action do |global_options,options,args|
      artist = options[:artist] || bridge.current_artist
      count = options[:count]
      say shows_for(artist, count)
    end
  end

  ### Authenticated methods

  desc 'Show the current Rdio user'
  command :user do |c|
    c.action do |global_options,options,args|
      user = current_user
      say "#{user['firstName']} #{user['lastName']}"
    end
  end

  desc 'Add the current track or album to your collection'
  command :snag do |c|
    c.action do |global_options,options,args|
      case args.shift
      when 'album'
        add_to_collection current_album_track_keys
      when nil
        add_to_collection current_track_key
      end
    end
  end

  pre do |global,command,options,args|
    # Pre logic here
    # Return true to proceed; false to abourt and not call the
    # chosen command
    # Use skips_pre before a command to skip this block
    # on that command only
    @consumer_key    = global[:consumer_key]
    @consumer_secret = global[:consumer_secret]
    @access_token    = global[:access_token]
    @access_secret   = global[:access_secret]
    if api.token.nil? || api.token.compact.empty?
      say 'Rdio credentials not found. Please run: rdio authorize'

      false
    else
      true
    end
  end

  post do |global,command,options,args|
    # Post logic here
    # Use skips_post before a command to skip this
    # block on that command only
  end

  on_error do |exception|
    # Error logic here
    # return false to skip default error handling
    true
  end

end


