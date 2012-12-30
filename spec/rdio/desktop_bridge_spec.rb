require 'spec_helper'

describe 'Rdio::DesktopBridge' do

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

  context "displaying now playing info" do

    before do
      @bridge.stub(:current_track).and_return("Hurt")
      @bridge.stub(:current_artist).and_return("Johnny Cash")
      @bridge.stub(:current_album).and_return("The Man Comes Around")
    end

    it "displays track, artist, and album by default" do
      expect(@bridge.now_playing).to \
        eq("Now playing: Hurt / Johnny Cash / The Man Comes Around")
    end

  end

end
