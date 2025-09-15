module WebRake
  class Engine < ::Rails::Engine
    isolate_namespace WebRake

    initializer 'web_rake.mount_routes' do |app|
      app.routes.append do
        mount WebRake::Engine, at: '/rails/tasks'
      end
    end

    initializer 'web_rake.configure_credentials' do |app|
      WebRake.username = ENV.fetch('WEB_RAKE_USERNAME', 'admin')
      WebRake.password = ENV.fetch('WEB_RAKE_PASSWORD', 'password')
    end
  end
end