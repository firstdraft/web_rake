require 'spec_helper'

RSpec.describe WebRake do
  it 'has a version number' do
    expect(WebRake::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'allows setting username and password' do
      WebRake.configure do |config|
        config.username = 'test_user'
        config.password = 'test_pass'
      end

      expect(WebRake.username).to eq('test_user')
      expect(WebRake.password).to eq('test_pass')
    end
  end
end