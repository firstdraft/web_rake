module WebRake
  class TasksController < ApplicationController
    before_action :load_rake_tasks
    before_action :find_task, only: [:show, :execute]

    def index
      @tasks = Rake.application.tasks.select(&:comment).sort_by(&:name)
    end

    def show
      @task = find_task
    end

    def execute
      @task = find_task

      start_time = Time.current
      output = []
      errors = []
      success = false

      begin
        original_stdout = $stdout
        original_stderr = $stderr

        $stdout = StringIO.new
        $stderr = StringIO.new

        @task.reenable
        @task.invoke

        output = $stdout.string.split("\n")
        errors = $stderr.string.split("\n")
        success = true
      rescue => e
        errors << e.message
        errors.concat(e.backtrace) if Rails.env.development?
      ensure
        $stdout = original_stdout
        $stderr = original_stderr
        Rake.application.tasks.each(&:reenable)
      end

      end_time = Time.current
      duration = (end_time - start_time).round(2)

      render :execute, locals: {
        task: @task,
        output: output,
        errors: errors,
        success: success,
        duration: duration
      }
    end

    private

    def load_rake_tasks
      Rails.application.load_tasks unless Rake::Task.tasks.any?
    end

    def find_task
      task_name = params[:id].gsub('__', ':')
      Rake::Task[task_name]
    rescue => e
      redirect_to tasks_path, alert: "Task '#{task_name}' not found"
    end
  end
end