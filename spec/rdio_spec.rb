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

  it "returns now playing info" do
    Rdio.stub(:current_artist).and_return 'Johnny Cash'
    Rdio.stub(:current_track).and_return 'Hurt'
    Rdio.stub(:current_album).and_return 'The Man Comes Around'

    Rdio.run %w(current)

    expect($stdout.string).to eq("Now playing: Hurt / Johnny Cash / The Man Comes Around\n")
  end

  it "returns custom formatted now playing info" do
    Rdio.stub(:current_artist).and_return 'Johnny Cash'
    Rdio.stub(:current_track).and_return 'Hurt'
    Rdio.stub(:current_album).and_return 'The Man Comes Around'

    Rdio.run ["current", %Q(Now rocking %{track} by %{artist} from the album %{album})]

    expect($stdout.string).to eq("Now rocking Hurt by Johnny Cash from the album The Man Comes Around\n")
  end

end
