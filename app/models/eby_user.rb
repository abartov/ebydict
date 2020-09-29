require 'digest/sha1'
class EbyUser < ApplicationRecord

  has_many :eby_def_events, :foreign_key => "who"
  has_many :eby_defs, :through => :eby_def_events, :source => :thedef
  has_many :assigned_defs, :class_name => "EbyDef", :foreign_key => "assignedto"
  has_many :typed_defs, -> { where eby_def_events: {old_status: 'NeedTyping'} }, :class_name => "EbyDef", :through => :eby_def_events, :source => :eby_def
  has_many :proofed_defs, -> { where "eby_def_events.old_status LIKE 'NeedProof%'"}, :class_name => "EbyDef", :through => :eby_def_events, :source => :eby_def
  has_many :first_proofed_defs, -> { where eby_def_events: {old_status: 'NeedProof1'}}, :class_name => "EbyDef", :through => :eby_def_events, :source => :eby_def
  has_many :second_proofed_defs, -> { where eby_def_events: {old_status: 'NeedProof2'}}, :class_name => "EbyDef", :through => :eby_def_events, :source => :eby_def
  has_many :fixed_defs, -> {where eby_def_events: {old_status: 'NeedFixup'}}, :class_name => "EbyDef", :through => :eby_def_events, :source => :eby_def

  validates :does_arabic, :does_extra, :does_greek, :does_russian, inclusion: { in: [true, false] }, allow_nil: true
  validates :role_fixer, :role_partitioner, :role_proofer, :role_publisher, :role_typist, inclusion: { in: [true, false] }, allow_nil: true
  validates :max_proof_level, numericality: true, allow_nil: true
#  validates :password, presence: true, length: { minimum: 4 }
  validates :fullname, presence: true, length: { minimum: 3 }
  validates :email, presence: true, length: { minimum: 5 }
#  validates_uniqueness_of :login, :on => :create, :message => I18n.t(:user_login_not_unique)
#  validates_length_of :login, :within => 3..40, :message => I18n.t(:user_login_bad_length)
#  validates_presence_of :login, :message => I18n.t(:user_login_cant_be_blank)

  def self.authenticate(login, pass)
    begin
      u = find_by_login(login)
      if u.nil?
        u = find_by_email(login) # try both
      end
      #u = find_by_login(login) || find_by_email(login) # try both
      return (u.password == hashfunc(pass) ? u : nil)
      # TODO: add salting to hashfunc?  store the salt in the user record, and use to hash the provided password before comparing...
    rescue
      return nil
    end
  end

  def self.hashfunc(str)
    return Digest::SHA1.hexdigest("Moose2402--#{str}--")[0..39]
  end

  def self.populate_from_omniauth(auth, user)
    user.provider = auth.provider
    user.uid = auth.uid
    user.fullname = auth.info.name
    user.email = auth.info.email
    user.oauth_token = auth.credentials.token
    user.oauth_expires_at = Time.at(auth.credentials.expires_at) unless auth.credentials.expires_at.nil?
    user.role_typist = true # start out as a typist
    user.save!
    return user
  end
  # new, Omniauth-based authentication
  def self.from_omniauth(auth)
    existing = where(email: auth.info.email) # merge into existing account if email matches!
    unless existing.empty?
      user = existing[0]
      user = populate_from_omniauth(auth, user)
    else
      where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
        user = populate_from_omniauth(auth, user)
      end
    end
  end

  def list_roles
    ret = []
    ret << I18n.t(:user_partitioner) if role_partitioner
    ret << I18n.t(:user_typist) if role_typist
    ret << I18n.t(:user_proofer)+' '+I18n.t(:user_proofs_up_to)+' '+max_proof_level.to_s if role_proofer
    ret << I18n.t(:user_fixer) if role_fixer
    ret << I18n.t(:user_publisher) if role_publisher
    return ret.join('; ')
  end
  protected

#  after_validation :crypt_password
#  def crypt_password
#      write_attribute("password", EbyUser.hashfunc(rec.password))
#  end

# TODO: fix the below validations! (somehow related to attr_accessor?)
# validates_presence_of :password, :message => :user_password_cant_be_blank.l
#  validates_length_of :password, :within => 5..41, :message => :user_password_bad_length.l

end
