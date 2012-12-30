require 'spec_helper'

describe Rdio do

  before :each do
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after :each do
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  context "with an empty config file" do
    before do
      FileUtils.rm_f Dir.glob('tmp/fakehome/.rdio')
    end

    it "prompts for Rdio keys" do
      HighLine.any_instance.should_receive(:say).twice
      HighLine.any_instance.should_receive(:ask).with("Enter your Rdio API key: ").and_return('vh5150')
      HighLine.any_instance.should_receive(:ask).with("Enter your Rdio API secret: ").and_return('0U812')
      Api.any_instance.should_receive(:begin_authentication).with('oob').and_return('http://api.developer.com/confirm/blah')
      Launchy.should_receive(:open)
      HighLine.any_instance.should_receive(:ask).
        with("Copy the four digit code from your browser. [ENTER] to continue. ").
        and_return("\n")
      HighLine.any_instance.should_receive(:ask).
        with("Code: ").
        and_return("1337")
      Api.any_instance.should_receive(:complete_authentication).with('1337').and_return(['abcdefg', '1234567890'])
      HighLine.any_instance.should_receive(:say)

      Rdio.run %w(authorize)

      config = YAML.load_file(File.expand_path(File.join(ENV['HOME'], '.rdio')))
      expect(config[:access_token]).to eq('abcdefg')
      expect(config[:access_secret]).to eq('1234567890')

    end
  end

  context "now playing" do

    before do
      Rdio::DesktopBridge.any_instance.stub(:current_artist).and_return 'Johnny Cash'
      Rdio::DesktopBridge.any_instance.stub(:current_track).and_return 'Hurt'
      Rdio::DesktopBridge.any_instance.stub(:current_album).and_return 'The Man Comes Around'
    end


    it "returns now playing info" do
      HighLine.any_instance.should_receive(:say).
        with("Now playing: Hurt / Johnny Cash / The Man Comes Around")

      Rdio.run %w(current)
    end

    it "returns custom formatted now playing info" do
      HighLine.any_instance.should_receive(:say).
        with("Now rocking Hurt by Johnny Cash from the album The Man Comes Around")

      Rdio.run ["current", %Q(Now rocking %{track} by %{artist} from the album %{album})]
    end

  end

  context "playback" do
    it "starts playback" do
      Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
        with("tell app \"Rdio\" to play")

      Rdio.run %w(play)
    end

    it "pauses playback" do
      Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
        with("tell app \"Rdio\" to pause")

      Rdio.run %w(pause)
    end

    it "toggles playback" do
      Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
        with("tell app \"Rdio\" to playpause")

      Rdio.run %w(toggle)
    end

    it "skips to the next track" do
      Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
        with("tell app \"Rdio\" to next track")

      Rdio.run %w(next)
    end

    it "goes back to the previous track" do
      Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
        with("tell app \"Rdio\" to previous track")

      Rdio.run %w(previous)
    end
  end

  it "exits" do
    Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
      with("tell app \"Rdio\" to quit")

    Rdio.run %w(q)
  end
  context "when authenticated" do
    before do
      config = {
        :consumer_key    => 'fup94efx5qgb2uunev7dsdyt',
        :consumer_secret => 'YdvEwYJsUj5w',
        :access_key      => 'fczfuy25vf83bzz35hw6p5pc8ft5ur6wsb8u5dcqa5zwbzbwrvfzbudpnwx2b3nz',
        :access_secret   => 'exyNUP88Ur'
      }
      File.open('tmp/fakehome/.rdio', 'w') do |out|
        YAML.dump(config, out)
      end
    end

    it "snags the currently playing track to your collection" do
      Rdio.stub(:current_track_key).and_return('t12345')
      Api.any_instance.should_receive(:call).
        with('addToCollection', {:keys => 't12345'})

      Rdio.run ['snag']
    end
  end

end
