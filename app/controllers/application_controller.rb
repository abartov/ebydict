# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class VolumeNotCompletelyPartitioned < Exception

end
class ApplicationController < ActionController::Base
protect_from_forgery
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
#  protect_from_forgery # :secret => '41d135963f34bdf8585e0669d6f4e890'

#  after_filter :set_charset

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
  #FILEBASE = '/BenYehuda/scans'
  FILEBASE = '/var/www'
  LAST_PROOF_ROUND = 3

  def url_from_file(filename)
    return nil if filename.nil?
    fmatch = filename.match(FILEBASE)
    if fmatch.nil?
      return nil
    end
    filepart = fmatch.post_match
    url = AppConstants.scanurlbase + filepart
    return url
  end

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
  def current_user
    @current_user ||= session[:user] if session[:user]
  end

  protected
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  def login_required
    if secure? && session[:user].nil?
      session["return_to"] = request.original_url # save intended uri for after successful login
      #session["return_to"] = request.request_uri # save intended uri for after successful login # rails 2.1.2
      redirect_to :controller => 'login', :action => 'login'
      return false
    end
  end
end
