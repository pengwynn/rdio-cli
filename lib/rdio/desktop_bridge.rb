module Rdio
  class DesktopBridge

    def apple_script(cmd)
      `osascript -e '#{cmd}'`
    end

    def tell_rdio(cmd)
      apple_script "tell app \"Rdio\" to #{cmd}"
    end

    def current_track
      tell_rdio('name of the current track').gsub(/\n/, '')
    end

    def current_artist
      tell_rdio('artist of the current track').gsub(/\n/, '')
    end

    def current_album
      tell_rdio('album of the current track').gsub(/\n/, '')
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

    def rdio_url(protocol = 'http')
      path = tell_rdio 'rdio url of the current track'
      "#{protocol}://www.rdio.com#{path}"
    end

  end
end
