namespace :dict do
  desc "Export published definitions to JSON files (one per volume) in public/json_export/. Use ALL=1 to dump all entries (default: 50 per volume)."
  task :json_export => :environment do
    dump_all = %w[1 true yes].include?(ENV['ALL'].to_s.downcase)
    limit = dump_all ? nil : 50

    output_dir = Rails.root.join('public', 'json_export')
    FileUtils.mkdir_p(output_dir)

    maxvol = EbyDef.maximum(:volume).to_i
    puts "EbyDict JSON export — volumes 1 to #{maxvol} (#{dump_all ? 'all' : "up to #{limit} per volume"})"

    maxvol.times do |i|
      vol = i + 1

      if EbyDef.where(status: 'Published', volume: vol, ordinal: nil).exists?
        abort "Volume #{vol} has Published defs with NULL ordinals. Run dict:export first to enumerate the volume."
      end

      scope = EbyDef.includes(:aliases).where(status: 'Published', volume: vol).order(:ordinal)
      scope = scope.limit(limit) unless dump_all

      entries = scope.map do |d|
        {
          defhead:    d.defhead,
          deftext:    d.deftext,
          footnotes:  d.footnotes,
          updated_at: d.updated_at,
          aliases:    d.aliases.map(&:alias)
        }
      end

      path = output_dir.join("volume_#{vol}.json")
      File.write(path, JSON.pretty_generate(entries))
      puts "Volume #{vol}: #{entries.size} entries → #{path}"
    end

    puts "Done."
  end
end
