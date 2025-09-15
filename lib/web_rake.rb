require 'web_rake/version'
require 'web_rake/engine'

module WebRake
  mattr_accessor :username
  mattr_accessor :password

  def self.configure
    yield self
  end
end