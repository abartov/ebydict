require 'eby_utils'
include EbyUtils
desc "Migrate all local scans and def parts to S3"
task :migrate_to_cloud  => :environment do
  grandtotal = 0
  granddone = 0
  coll = EbyScanImage.left_joins(:cloug_origjpeg_attachment).group(:id).having("COUNT(active_storage_attachments) = 0")
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
      logger.error "exception caught while migrating origjpeg! #{$!}\n#{exception.backtrace}"
    end
  end
  granddone += done
  puts "Migrating EbyScanImages - smalljpegs (#{total} left)"
  coll = EbyScanImage.left_joins(:cloug_smalljpeg_attachment).group(:id).having("COUNT(active_storage_attachments) = 0")
  total = coll.count
  grandtotal += total
  done = 0
  coll.each do |sc|
    begin
      sc.cloud_smalljpeg.attach(io: File.open(sc.smalljpeg), filename: filepart_from_path(sc.smalljpeg))
      done += 1
      print "... #{done}" if done % 20 == 0
    rescue => exception
      logger.error "exception caught while migrating smalljpeg! #{$!}\n#{exception.backtrace}"
    end
  end
  granddone += done
=begin   
  puts "Migrating EbyColumnImages (#{total} left)"
  total = coll.count
  grandtotal += total
  done = 0

  granddone += done
  puts "Migrating EbyColumnImage def sections (#{total} left)"
  total = coll.count
  grandtotal += total
  done = 0

  granddone += done
  puts "Migrating EbyColumnImage footnote sections (#{total} left)"
  total = coll.count
  grandtotal += total
  done = 0

  granddone += done
  puts "Migrating EbyDefPartImages (#{total} left)"
  total = coll.count
  grandtotal += total
  done = 0

  granddone += done
 =end  

 puts "done!"
end

private 

