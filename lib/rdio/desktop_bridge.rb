module Rdio
  class DesktopBridge

    def apple_script(cmd)
      `osascript -e '#{cmd}'`
    end

    def tell_rdio(cmd)
      apple_script "tell app \"Rdio\" to #{cmd}"
    end

    def quit
      # apple_script "tell application \"Rdio\" to quit"
      tell_rdio "quit"
    end

    def play
      tell_rdio "play"
    end

    def pause
      tell_rdio "pause"
    end

    def toggle
      tell_rdio "playpause"
    end

    def next_track
      tell_rdio "next track"
    end

    def previous_track
      tell_rdio "previous track"
    end

    def current_track
      tell_rdio('name of the current track').chomp
    end

    def current_artist
      tell_rdio('artist of the current track').chomp
    end

    def current_album
      tell_rdio('album of the current track').chomp
    end

    def now_playing(text=nil)
      text ||= "Now playing: %{track} / %{artist} / %{album}"
      text % {
        :artist => current_artist,
        :track  => current_track,
        :album  => current_album
      }
    end

    def set_volume(pct = 30)
      tell_rdio "set the sound volume to #{pct}"
    end

    def current_url(protocol = 'http')
      path = tell_rdio('rdio url of the current track').chomp

      path.empty? ? nil : "#{protocol}://www.rdio.com#{path}"
    end

  end
end
