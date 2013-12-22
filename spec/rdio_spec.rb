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
      FileUtils.rm_f Dir.glob(File.join(ENV['HOME'], '.rdio'))
    end

    after do
      FileUtils.rm_f Dir.glob(File.join(ENV['HOME'], '.rdio'))
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

  context "with Rdio app running" do
    before do
      Rdio::DesktopBridge.any_instance.should_receive(:apple_script).
        with('tell application "System Events" to get the name of every process whose background only is false').
        and_return('Finder, Rdio, Something Else')
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
  end

  context "when authenticated" do
    let(:api) { Rdio.api }
    let(:consumer_key) { "fup94efx5qgb2uunev7dsdyt" }
    let(:consumer_secret) { "YdvEwYJsUj5w" }
    let(:access_token) { "fczfuy25vf83bzz35hw6p5pc8ft5ur6wsb8u5dcqa5zwbzbwrvfzbudpnwx2b3nz" }
    let(:access_secret) { "exyNUP88Ur" }
    let(:auth_args) { ["--consumer_key=#{consumer_key}",
                       "--consumer_secret=#{consumer_secret}",
                       "--access_token=#{access_token}",
                       "--access_secret=#{access_secret}"] }

    def run(*args)
      Rdio.run auth_args.concat(args)
    end

    before(:each) do
      api.token = [:present]
    end

    it "snags the currently playing track to your collection" do
      Rdio.stub(:current_track_key).and_return('t12345')
      api.should_receive(:call).
        with('addToCollection', {:keys => 't12345'})

      run 'snag'
    end

    it "snags the currently playing album tracks to your collection" do
      Rdio.stub(:current_album_track_keys).and_return(['t12345', 't23456', 't34567'])
      api.should_receive(:call).
        with('addToCollection', {:keys => 't12345,t23456,t34567'})

      run 'snag', 'album'
    end

    context "friends" do
      it "handles when it can't find a friend" do
        HighLine.any_instance.should_receive(:say).
          with("Could not find user nonexistent.")
        api.should_receive(:call).with('findUser', {:vanityName => 'nonexistent'}).
          and_return({ 'result' => nil })
        api.should_not_receive(:call).with('addFriend', {:user => 'pengwynn_key'})

        run 'friends', 'add', 'nonexistent'
      end

      it "adds a friend unsuccessfully" do
        HighLine.any_instance.should_receive(:say).
          with("Rdio said you were unable to become friends with obama.")
         api.should_receive(:call).with('findUser', {:vanityName => 'obama'}).
          and_return({ 'result' => { 'key' => 'obama_key' } })
        api.should_receive(:call).with('addFriend', {:user => 'obama_key'}).
          and_return({ 'result' => false })

        run 'friends', 'add', 'obama'
      end

      it "adds a friend by vanityName successfully" do
        HighLine.any_instance.should_receive(:say).
          with("You are now friends with pengwynn.")
         api.should_receive(:call).with('findUser', {:vanityName => 'pengwynn'}).
          and_return({ 'result' => { 'key' => 'pengwynn_key' } })
        api.should_receive(:call).with('addFriend', {:user => 'pengwynn_key'}).
          and_return({ 'result' => true })

        run 'friends', 'add', 'pengwynn'
      end

      it "adds a friend by email successfully" do
        HighLine.any_instance.should_receive(:say).
          with("You are now friends with pengwynn@github.com.")
         api.should_receive(:call).with('findUser', {:email => 'pengwynn@github.com'}).
          and_return({ 'result' => { 'key' => 'pengwynn_key' } })
        api.should_receive(:call).with('addFriend', {:user => 'pengwynn_key'}).
          and_return({ 'result' => true })

        run 'friends', 'add', 'pengwynn@github.com'
      end
    end
  end

  context "lyrics" do

    before do
      Rdio::DesktopBridge.any_instance.stub(:current_artist).and_return 'Johnny Cash'
      Rdio::DesktopBridge.any_instance.stub(:current_track).and_return 'Hurt'
    end

    it "looks up lyrics for current track" do
      stub = stub_get("http://makeitpersonal.co/lyrics?artist=Johnny%20Cash&title=Hurt").
               to_return(:body => fixture('hurt.txt'))

      HighLine.any_instance.should_receive(:say)
      Rdio.run %w(lyrics)

      expect(stub).to have_been_made
    end

    it "looks up lyrics for any artist and title" do
      stub = stub_get("http://makeitpersonal.co/lyrics?artist=Eric%20Clapton&title=Layla").
               to_return(:body => fixture('layla.txt'))

      HighLine.any_instance.should_receive(:say)
      Rdio.run [
        'lyrics',
        '--artist=Eric Clapton',
        '--title=Layla'
      ]

      expect(stub).to have_been_made
    end

  end

  context "shows" do

    before do
      Rdio::DesktopBridge.any_instance.stub(:current_artist).and_return 'The Black Keys'
    end

    it "looks up upcoming shows for current artist" do
      stub = stub_get("http://ws.audioscrobbler.com/2.0?method=artist.getEvents&artist=The+Black+Keys&limit=10&format=json&autocorrect=1&api_key=3c3e4b39c2aedcac5d745c70a898ee76").
               to_return(:body => fixture('the_black_keys.txt'))

      HighLine.any_instance.should_receive(:say)
      Rdio.run %w(shows)

      expect(stub).to have_been_made
    end

    it "looks up upcoming shows for any artist" do
      stub = stub_get("http://ws.audioscrobbler.com/2.0?method=artist.getEvents&artist=Eric+Clapton&limit=10&format=json&autocorrect=1&api_key=3c3e4b39c2aedcac5d745c70a898ee76").
               to_return(:body => fixture('eric_clapton.txt'))

      HighLine.any_instance.should_receive(:say)
      Rdio.run [
        'shows',
        '--artist=Eric Clapton'
      ]

      expect(stub).to have_been_made
    end

  end

end
