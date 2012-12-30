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
