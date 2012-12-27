require 'gli'
require 'yaml'
require 'launchy'

require 'api'
require 'rdio/version'
require 'highline/import'

module Rdio
  extend GLI::App

  program_desc 'Simple CLI for Rdio'

  version Rdio::VERSION

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

  def self.apple_script(cmd)
    `osascript -e '#{cmd}'`
  end

  def self.tell_rdio(cmd)
    apple_script "tell app \"Rdio\" to #{cmd}"
  end

  def self.current_track
    tell_rdio('name of the current track').gsub(/\n/, '')
  end

  def self.current_artist
    tell_rdio('artist of the current track').gsub(/\n/, '')
  end

  def self.current_album
    tell_rdio('album of the current track').gsub(/\n/, '')
  end

  def self.display_track(text)
    text = "Now playing: %{track} / %{artist} / %{album}" if text.nil?
    say (text % {
      :artist => current_artist,
      :track  => current_track,
      :album  => current_album
    })
  end

  def self.set_volume(pct = 30)
    tell_rdio "set the sound volume to #{pct}"
  end

  def self.rdio_url
    path = tell_rdio 'rdio url of the current track'
    "http://www.rdio.com#{path}"
  end

  config_file '.rdio'

  flag :consumer_key
  flag :consumer_secret
  flag :access_token
  flag :access_secret

  desc 'Plays the current track'
  command :play do |c|
    c.action do |global_options,options,args|
      tell_rdio "play"
    end
  end

  desc 'Pause the player'
  skips_pre
  command :pause do |c|
    c.action do |global_options,options,args|
      tell_rdio "pause"
    end
  end

  desc 'Toggle playback'
  skips_pre
  command :toggle do |c|
    c.action do |global_options,options,args|
      tell_rdio "playpause"
    end
  end

  desc 'Display the current track info'
  long_desc %(
    Display current track, artist, and album info. Pass
    format string for custom output using
    %{track}, %{artist}, and %{album} placeholders.
  )
  arg_name 'format'
  skips_pre
  command :current do |c|
    c.action do |global_options,options,args|
      display_track args.first
    end
  end

  desc 'Skip to next track'
  skips_pre
  command :next do |c|
    c.action do |global_options,options,args|
      tell_rdio "next track"
    end
  end

  desc 'Play previous track'
  skips_pre
  command :previous, :prev do |c|
    c.action do |global_options,options,args|
      tell_rdio "previous track"
    end
  end

  desc 'Open the current track in Rdio player'
  skips_pre
  command :browse do |c|
    c.action do |global_options,options,args|
      exec "open '#{rdio_url}'"
    end
  end

  desc 'Set volume for player'
  skips_pre
  arg_name 'level'
  command :volume, :vol do |c|
    c.action do |global_options,options,args|
      level = args.shift.to_i
      set_volume level
    end
  end

  desc 'Mute the Rdio player'
  skips_pre
  command :mute do |c|
    c.action do |global_options,options,args|
      set_volume 0
    end
  end

  desc 'Get a shareable link for the current track'
  skips_pre
  command :link do |c|
    c.action do |global_options,options,args|
      say rdio_url
    end
  end

  desc "Get CLI and application version info"
  skips_pre
  command :version, :v do |c|
    c.action do |global_options,options,args|
      say "rdio-cli #{Rdio::VERSION} / Rdio #{apple_script('get version of application "Rdio"')}"
    end
  end

  desc "Quit Rdio"
  skips_pre
  command :quit, :q do |c|
    c.action do |global_options,options,args|
      apple_script "tell application \"Rdio\" to quit"
    end
  end

  desc "Authorize Rdio account"
  skips_pre
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

  ### Authenticated methods

  desc 'Show the current Rdio user'
  command :user do |c|
    c.action do |global_options,options,args|
      user = api.call('currentUser')['result']
      say "#{user['firstName']} #{user['lastName']}"
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
    if api.token.compact.empty?
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


