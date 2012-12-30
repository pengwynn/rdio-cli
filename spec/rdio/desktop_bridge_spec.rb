require 'spec_helper'

describe Rdio::DesktopBridge do

  before do
    @bridge = Rdio::DesktopBridge.new
  end

  it "sends AppleScript to Rdio.app" do
    @bridge.should_receive(:apple_script).
      with("tell app \"Rdio\" to name of the current track")

    @bridge.tell_rdio("name of the current track")
  end

  it "gets the name of the current track" do
    @bridge.should_receive(:apple_script).
      with("tell app \"Rdio\" to name of the current track").
      and_return("Hurt\n")

    track = @bridge.current_track
    expect(track).to eq('Hurt')
  end

  it "gets the name of the current artist" do
    @bridge.should_receive(:apple_script).
      with("tell app \"Rdio\" to artist of the current track").
      and_return("Johnny Cash\n")

    artist = @bridge.current_artist
    expect(artist).to eq('Johnny Cash')
  end

  it "gets the name of the current album" do
    @bridge.should_receive(:apple_script).
      with("tell app \"Rdio\" to album of the current track").
      and_return("The Man Comes Around\n")

    album = @bridge.current_album
    expect(album).to eq('The Man Comes Around')
  end

  it "sets the volume of Rdio.app" do
    @bridge.should_receive(:apple_script).
      with("tell app \"Rdio\" to set the sound volume to 40")

    @bridge.set_volume(40)
  end

  context "playback" do
    it "starts playback" do
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to play")

      @bridge.play
    end

    it "pauses playback" do
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to pause")

      @bridge.pause
    end

    it "toggles playback" do
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to playpause")

      @bridge.toggle
    end

    it "skips to the next track" do
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to next track")

      @bridge.next_track
    end

    it "goes back to the previous track" do
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to previous track")

      @bridge.previous_track
    end
  end

  it "exits" do
    @bridge.should_receive(:apple_script).
      with("tell app \"Rdio\" to quit")

    @bridge.quit
  end

  context "displaying now playing info" do

    it "displays track, artist, and album by default" do
      @bridge.stub(:current_track).and_return("Hurt")
      @bridge.stub(:current_artist).and_return("Johnny Cash")
      @bridge.stub(:current_album).and_return("The Man Comes Around")

      expect(@bridge.now_playing).to \
        eq("Now playing: Hurt / Johnny Cash / The Man Comes Around")
    end

    it "handles nothing playing" do
      @bridge.stub(:current_track).and_return('')
      @bridge.stub(:current_artist).and_return('')
      @bridge.stub(:current_album).and_return('')

      expect(@bridge.now_playing).to eq("Nothing playing")
    end

  end

  context "URLs" do

    it "grabs the URL for the current track from Rdio.app" do
      path = "/artist/Josh_Garrels/album/Love__War__The_Sea_In_Between/track/White_Owl/"
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to rdio url of the current track").
        and_return(path + "\n")

      expect(@bridge.current_url).to \
        eq("http://www.rdio.com#{path}")
    end

    it "does not return a URL when nothing is playing" do
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to rdio url of the current track").
        and_return("\n")

      expect(@bridge.current_url).to be_nil
    end

    it "can use the rdio:// scheme" do
      path = "/artist/Josh_Garrels/album/Love__War__The_Sea_In_Between/track/White_Owl/"
      @bridge.should_receive(:apple_script).
        with("tell app \"Rdio\" to rdio url of the current track").
        and_return(path + "\n")

      expect(@bridge.current_url('rdio')).to \
        eq("rdio://www.rdio.com#{path}")
    end
  end

end
