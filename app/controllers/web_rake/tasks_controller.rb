module WebRake
  class TasksController < ApplicationController
    before_action :ensure_environment_loaded

    def index
      @tasks = custom_tasks.sort_by(&:name)
    end

    def show
      @task = find_task
      redirect_to tasks_path, alert: "Task not found" unless @task
    end

    def execute
      task_name = params[:id].gsub('__', ':')

      # Check if this is one of our custom tasks
      unless extract_task_names_from_files.include?(task_name)
        redirect_to tasks_path, alert: "Task not found"
        return
      end

      start_time = Time.current
      output = []
      errors = []
      success = false

      begin
        original_stdout = $stdout
        original_stderr = $stderr

        $stdout = StringIO.new
        $stderr = StringIO.new

        # Run the rake task in a subprocess to avoid state issues
        # This ensures clean execution every time
        require 'open3'

        # Build the rake command
        rake_command = "bundle exec rake #{task_name}"

        # Execute the command and capture output
        stdout_str, stderr_str, status = Open3.capture3(rake_command)

        output = stdout_str.split("\n")
        errors = stderr_str.split("\n") if stderr_str.present?
        success = status.success?
      rescue => e
        errors << e.message
        errors.concat(e.backtrace) if Rails.env.development?
      ensure
        $stdout = original_stdout if original_stdout
        $stderr = original_stderr if original_stderr
      end

      end_time = Time.current
      duration = (end_time - start_time).round(2)

      # Create a simple task object for the view
      task = OpenStruct.new(name: task_name)

      render :execute, locals: {
        task: task,
        output: output,
        errors: errors,
        success: success,
        duration: duration
      }
    end

    private

    def ensure_environment_loaded
      # Ensure Rails environment is available for tasks that depend on it
      Rails.application.load_tasks if Rake::Task.tasks.empty?
    end

    def custom_tasks
      # First, get the names of tasks defined in lib/tasks files
      custom_task_names = extract_task_names_from_files

      # Ensure all tasks are loaded
      Rails.application.load_tasks

      # Get only the tasks that match our custom task names
      custom_task_names.filter_map do |name|
        Rake::Task[name] rescue nil
      end.select(&:actions)
    end

    def extract_task_names_from_files
      task_names = []

      # Parse each rake file to extract task names
      Dir.glob(Rails.root.join('lib/tasks/**/*.rake')).each do |file|
        content = File.read(file)

        # Match various task definition patterns

        # Pattern for: task({ :sample_data => :environment })
        content.scan(/task\s*\(\s*\{\s*:([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/).each do |match|
          task_names << match[0]
        end

        # Pattern for: task :sample_data => :environment
        content.scan(/task\s+:([a-zA-Z_][a-zA-Z0-9_]*)\s*=>/).each do |match|
          task_names << match[0]
        end

        # Pattern for: task "sample_data" => :environment
        content.scan(/task\s+["']([a-zA-Z_][a-zA-Z0-9_]*)["']\s*=>/).each do |match|
          task_names << match[0]
        end

        # Pattern for: task sample_data: :environment (Ruby 1.9+ syntax)
        content.scan(/task\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*:/).each do |match|
          task_names << match[0]
        end

        # Pattern for: task(:sample_data)
        content.scan(/task\s*\(\s*:([a-zA-Z_][a-zA-Z0-9_]*)\s*\)/).each do |match|
          task_names << match[0]
        end

        # Pattern for: desc "..." \n task :name
        content.scan(/desc\s+.*?\n\s*task\s+:([a-zA-Z_][a-zA-Z0-9_]*)/).each do |match|
          task_names << match[0]
        end
      end

      task_names.uniq
    end

    def find_task
      task_name = params[:id].gsub('__', ':')

      # Check if this is one of our custom tasks
      return nil unless extract_task_names_from_files.include?(task_name)

      # Ensure tasks are loaded
      Rails.application.load_tasks

      # Find the task
      Rake::Task[task_name] rescue nil
    end
  end
end