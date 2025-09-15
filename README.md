# WebRake

WebRake is a Rails engine designed for production environments that provides a secure web interface for executing essential Rake tasks in your deployed Rails application. It includes HTTP basic authentication for security and automatically mounts at `/rails/tasks` without requiring any route configuration.

## Purpose

This gem is specifically designed for production/deployed applications where you need quick access to:
- Seed your database with `db:seed`
- Run custom data population tasks (like `sample_data`)
- Execute other custom maintenance tasks

Perfect for situations where you don't have shell access or need to quickly run tasks on deployed platforms like Render, Heroku, or similar services.

## Features

- Exposes `db:seed` and custom Rake tasks from `lib/tasks/` directory
- Web interface with one-click task execution
- HTTP basic authentication for security
- Real-time output capture (stdout and stderr)
- Execution timing and status reporting
- Clean, responsive UI
- Zero configuration required for routes

## Which Tasks Are Shown

WebRake displays:
- The `db:seed` task for database seeding
- Custom Rake tasks defined in your `lib/tasks/` directory

System tasks (like `db:migrate`, `db:drop`, `assets:precompile`, etc.) are intentionally hidden for security reasons.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'web_rake'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install web_rake
```

## Configuration

### Environment Variables

WebRake uses HTTP basic authentication to protect access to the rake task interface. Set these environment variables in your `.env` file or deployment configuration:

```bash
WEB_RAKE_USERNAME=your_username
WEB_RAKE_PASSWORD=your_secure_password
```

**Important:** Choose strong credentials, especially in production environments, as anyone with these credentials can execute rake tasks on your application.

### Optional Ruby Configuration

You can also configure the credentials programmatically in an initializer:

```ruby
# config/initializers/web_rake.rb
WebRake.configure do |config|
  config.username = 'custom_username'
  config.password = 'custom_password'
end
```

Note: Environment variables take precedence over Ruby configuration.

## Usage

Once installed and configured, WebRake automatically mounts at `/rails/tasks` in your Rails application.

1. Navigate to `http://your-app.com/rails/tasks`
2. Enter your HTTP basic auth credentials
3. You'll see a list of all available Rake tasks with descriptions
4. Click "Run Task" on any task to execute it
5. View the output, errors (if any), and execution time

## How It Works

- WebRake is a Rails engine that automatically mounts itself at `/rails/tasks`
- It discovers all loaded Rake tasks in your Rails application
- Tasks are executed in the same process as your Rails app
- Output is captured using StringIO redirection
- Tasks are automatically re-enabled after execution for repeat runs

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/firstdraft/web_rake.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
