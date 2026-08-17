require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

# Every Tuesday and Friday at 2:00AM
scheduler.cron '0 2 * * 2,5 Asia/Jerusalem' do
  system('bin/rake', 'dict:export')
end
