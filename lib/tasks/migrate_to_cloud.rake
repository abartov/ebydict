require 'eby_utils'
include EbyUtils
desc "Migrate all local scans and def parts to S3"
task :migrate_to_cloud  => :environment do
  grandtotal = 0
  granddone = 0
  coll = EbyScanImage.left_joins(:cloud_origjpeg_attachment).where(active_storage_attachments: {id: nil})
  total = coll.count
  puts "Migrating EbyScanImages - origjpegs (#{total} left)"
  grandtotal += total
  done = 0
  coll.each do |sc|
    begin
      sc.cloud_origjpeg.attach(io: File.open(sc.origjpeg), filename: filepart_from_path(sc.origjpeg))
      done += 1
      print "... #{done}" if done % 20 == 0
    rescue => exception
      Rails.logger.error "exception caught while migrating origjpeg! #{$!}\n#{exception.backtrace}"
    end
  end
  granddone += done
  coll = EbyScanImage.left_joins(:cloud_smalljpeg_attachment).where(active_storage_attachments: {id: nil})
  total = coll.count
  puts "Migrating EbyScanImages - smalljpegs (#{total} left)"
  grandtotal += total
  done = 0
  coll.each do |sc|
    begin
      sc.cloud_smalljpeg.attach(io: File.open(sc.smalljpeg), filename: filepart_from_path(sc.smalljpeg))
      done += 1
      print "... #{done}" if done % 20 == 0
    rescue => exception
      Rails.logger.error "exception caught while migrating smalljpeg! #{$!}\n#{exception.backtrace}"
    end
  end
  granddone += done
  coll = EbyColumnImage.left_joins(:cloud_coljpeg_attachment).where(active_storage_attachments: {id: nil})
  total = coll.count
  puts "Migrating EbyColumnImages (#{total} left)"
  grandtotal += total
  done = 0
  coll.each do |c|
    begin
      c.cloud_coljpeg.attach(io: File.open(c.coljpeg), filename: filepart_from_path(c.coljpeg))
      done += 1
      print "... #{done}" if done % 20 == 0
    rescue => exception
      Rails.logger.error "exception caught while migrating smalljpeg! #{$!}\n#{exception.backtrace}"
    end
  end
  granddone += done
  coll = EbyColumnImage.left_joins(:cloud_coldefjpeg_attachment).where(active_storage_attachments: {id: nil})
  total = coll.count
  puts "Migrating EbyColumnImage def sections (#{total} left)"
  grandtotal += total
  done = 0
  skipped = 0
  coll.each do |c|
    if c.coldefjpeg != c.coljpeg
      begin
        c.cloud_coldefjpeg.attach(io: File.open(c.coldefjpeg), filename: filepart_from_path(c.coldefjpeg))
        done += 1
        print "... #{done}" if done % 20 == 0
      rescue => exception
        Rails.logger.error "exception caught while migrating coldefjpeg! #{$!}\n#{exception.backtrace}"
      end
    else
      skipped += 1
    end
  end
  puts "skipped #{skipped} coldefjpegs identical to coljpeg"
  granddone += done
  coll = EbyColumnImage.left_joins(:cloud_colfootjpeg_attachment).where(active_storage_attachments: {id: nil})
  total = coll.count
  puts "Migrating EbyColumnImage footnote sections (#{total} left)"
  grandtotal += total
  done = 0
  skipped = 0
  coll.each do |c|
    unless c.colfootjpeg.nil?
      begin
        c.cloud_colfootjpeg.attach(io: File.open(c.colfootjpeg), filename: filepart_from_path(c.colfootjpeg))
        done += 1
        print "... #{done}" if done % 20 == 0
      rescue => exception
        Rails.logger.error "exception caught while migrating colfootjpeg! #{$!}\n#{exception.backtrace}"
      end
    else
      skipped += 1
    end
  end
  puts "skipped #{skipped} empty colfootjpegs"
  granddone += done
  coll = EbyDefPartImage.left_joins(:cloud_defpartjpeg_attachment).where(active_storage_attachments: {id: nil})
  total = coll.count
  puts "Migrating EbyDefPartImages (#{total} left)"
  grandtotal += total
  done = 0
  skipped = 0
  coll.each do |dp|
    unless dp.filename.nil?
      begin
        dp.cloud_defpartjpeg.attach(io: File.open(dp.filename), filename: filepart_from_path(dp.filename))
        done += 1
        print "... #{done}" if done % 20 == 0
      rescue => exception
        Rails.logger.error "exception caught while migrating DefPartImage jpegs! #{$!}\n#{exception.backtrace}"
      end
    else
      puts "ERROR: DefPartImage #{dp.id} has no filename! Skipped."
      skipped += 1
    end
  end
  granddone += done
  puts "skipped #{skipped} erroneously empty defpartimages"

  puts "done!  Attached #{granddone} after processing #{grandtotal} total potential attachments."
end

private 

def filepart_from_path(path)
  return path[(path.rindex('/')+1)..-1]
end
