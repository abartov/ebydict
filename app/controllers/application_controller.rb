# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
protect_from_forgery
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
#  protect_from_forgery # :secret => '41d135963f34bdf8585e0669d6f4e890'

  after_filter :set_charset

  #  # TODO: return to charset=utf-8 once the Excel import iconvs properly
  # @headers["Content-Type"] = "text/html; charset=WINDOWS-1255"

  #Globalite.language = :he

  def set_charset
#    content_type = @headers["Content-Type"] || 'text/html'
#    if /^text\//.match(content_type)
#      @headers["Content-Type"] = "#{content_type}; charset=utf-8" 
     headers["Content-Type"] = "text/html; charset=utf-8"
  end

  # global consts
  URLBASE = AppConstants.urlbase
  #'http://localhost:80'
  #FILEBASE = '/BenYehuda/scans'
  FILEBASE = '/var/www'
  NEXT = 1
  PREV = -1
  LAST_PROOF_ROUND = 3

  def url_from_file(filename)
    return nil if filename.nil?
    fmatch = filename.match(FILEBASE)
    if fmatch.nil?
      return nil
    end
    filepart = fmatch.post_match
    url = URLBASE + filepart
    return url
  end
  def col_from_col(col, delta) # retrieves next or prev column image, based on given colimg object and delta (NEXT, PREV)
    return nil unless delta == NEXT || delta == PREV
    retcolnum = col.colnum + delta
    if retcolnum < 1 # look for prev scanimg
      page = col.pagenum-1
      prevscan = EbyScanImage.find(:first, :conditions => 'firstpagenum = '+page.to_s+' or secondpagenum = '+page.to_s)
      return nil if prevscan.nil?
      retcol = EbyColumnImage.find(:first, :conditions => 'eby_scan_image_id = '+prevscan.id.to_s, :order => 'colnum desc') # find LAST column of scan
    elsif retcolnum > col.scan.columns # look for next scanimg
      page = col.pagenum+1
      nextscan = EbyScanImage.find(:first, :conditions => 'firstpagenum = '+page.to_s+' or secondpagenum = '+page.to_s)
      return nil if nextscan.nil?
      retcol = EbyColumnImage.find(:first, :conditions => 'eby_scan_image_id = '+nextscan.id.to_s, :order => 'colnum asc') # find FIRST column of scan
    else # simple case - same scan, different col
      retcol = EbyColumnImage.find(:first, :conditions => "eby_scan_image_id = "+col.scan.id.to_s+" and colnum = #{retcolnum}")
    end
    return retcol
  end
  before_filter :login_required
  #before_filter [:set_locale, :login_required]

  protected
  def check_role(role)
    user = session['user']
    case role
      # surely, there's a neat short way to do this?
      when 'partitioner'
        bit = user.role_partitioner
      when 'typist'
        bit = user.role_typist
      when 'fixer'
        bit = user.role_fixer
      when 'proofer'
        bit = user.role_proofer
      when 'publisher'
        bit = user.role_publisher
      else
        bit = false
    end
#    if not bit
#      flash[:error] = "You're not responsible for that task.  Please stick to what you're supposed to do, or write Asaf"
#      redirect_to :controller => 'user'
#    end
    return bit
  end
  def secure?
    true # by default, everything requires a login
  end
  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end 
  def login_required
    if secure? && session["user"].nil?
      session["return_to"] = request.original_url # save intended uri for after successful login
      #session["return_to"] = request.request_uri # save intended uri for after successful login # rails 2.1.2
      redirect_to :controller => 'login', :action => 'login'
      return false
    end
  end
end
