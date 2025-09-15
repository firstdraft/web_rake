module WebRake
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :authenticate

    private

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == WebRake.username && password == WebRake.password
      end
    end
  end
end