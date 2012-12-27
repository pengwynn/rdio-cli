RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before(:suite) do
    @original_home = ENV['HOME']
    new_home = File.expand_path("./tmp/fakehome")
    ENV['HOME'] = new_home
  end

  config.after(:suite) do
    ENV['HOME'] = @original_home
  end
end

require 'rdio'
require 'rspec/mocks'
