module WebRake
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    http_basic_authenticate_with(
      name: -> { WebRake.username },
      password: -> { WebRake.password }
    )
  end
end