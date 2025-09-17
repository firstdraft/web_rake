require 'rake'
require 'open3'
require 'ostruct'

module WebRake
  class TasksController < ApplicationController
    before_action :ensure_environment_loaded

    def index
      @tasks = custom_tasks.sort_by(&:name)
    end

    def show
      @task = find_task
      redirect_to root_path, alert: "Task not found" unless @task
    end

    def execute
      task_name = params[:id].gsub('__', ':')

      # Use find_task to validate the task is allowed
      unless find_task
        redirect_to root_path, alert: "Task not found"
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
      # Ensure all tasks are loaded
      Rails.application.load_tasks

      tasks = []

      # Find tasks defined in lib/tasks or db:seed
      Rake.application.tasks.each do |task|
        next if task.actions.blank?

        if task_from_lib_tasks?(task) || task.name == "db:seed"
          tasks << task
        end
      end

      tasks
    end

    def find_task
      task_name = params[:id].gsub('__', ':')

      # Ensure tasks are loaded
      Rails.application.load_tasks

      # Find the task
      task = Rake::Task[task_name] rescue nil
      return nil unless task

      # Check if it's db:seed or defined in lib/tasks
      return task if task_name == 'db:seed'
      return task if task_from_lib_tasks?(task)

      nil
    end

    def task_from_lib_tasks?(task)
      return false if task.actions.blank?

      source_path = task.actions.first.source_location&.first
      source_path.present? && source_path.include?(Rails.root.join("lib/tasks").to_s)
    end
  end
end