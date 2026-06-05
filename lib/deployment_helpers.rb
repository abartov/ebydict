# frozen_string_literal: true

module DeploymentHelpers
  def self.assets_compilation?
    # Check if we're in assets group (set by rails assets:precompile)
    return true if ENV['RAILS_GROUPS'].to_s.include?('assets')

    # Fallback to checking rake tasks
    if defined?(Rake.application)
      Rake.application.top_level_tasks.any? do |task|
        task.to_s == 'assets:precompile'
      end
    end
  end
end
