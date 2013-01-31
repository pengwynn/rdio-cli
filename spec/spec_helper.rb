RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.order = 'random'

  config.before do
    unless ENV['CI']
      @original_home = ENV['HOME']
      new_home = File.expand_path("./tmp/fakehome")
      ENV['HOME'] = new_home
    end
  end

  config.after do
    ENV['HOME'] = @original_home unless ENV['CI']
  end
end

require 'rdio'
require 'rspec/mocks'
require 'webmock/rspec'

def a_delete(url)
  a_request(:delete, rdio_url(url))
end

def a_get(url)
  a_request(:get, rdio_url(url))
end

def a_patch(url)
  a_request(:patch, rdio_url(url))
end

def a_post(url)
  a_request(:post, rdio_url(url))
end

def a_put(url)
  a_request(:put, rdio_url(url))
end

def stub_delete(url)
  stub_request(:delete, rdio_url(url))
end

def stub_get(url)
  stub_request(:get, rdio_url(url))
end

def stub_head(url)
  stub_request(:head, rdio_url(url))
end

def stub_patch(url)
  stub_request(:patch, rdio_url(url))
end

def stub_post(url)
  stub_request(:post, rdio_url(url))
end

def stub_put(url)
  stub_request(:put, rdio_url(url))
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_response(file)
  {
    :body => fixture(file),
    :headers => {
      :content_type => 'application/json; charset=utf-8'
    }
  }
end

def rdio_url(url)
  if url =~ /^http/
    url
  else
    "https://api.rdio.com#{url}"
  end
end
