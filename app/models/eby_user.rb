require 'digest/sha1'
class EbyUser < ActiveRecord::Base
  attr_accessible :does_arabic, :does_extra, :does_greek, :does_russian, :email, :fullname, :login, :max_proof_level, :role_fixer, :role_partitioner, :role_proofer, :role_publisher, :role_typist

  has_many :eby_def_events, :foreign_key => "who"
  has_many :eby_defs, :through => :eby_def_events, :source => :thedef
  has_many :assigned_defs, :class_name => "EbyDef", :foreign_key => "assignedto"
  has_many :typed_defs, :class_name => "EbyDef", :through => :eby_def_events, :conditions => "old_status = 'NeedTyping'", :source => :thedef
  has_many :proofed_defs, :class_name => "EbyDef", :through => :eby_def_events, :conditions => "old_status LIKE 'NeedProof%'", :source => :thedef
  has_many :first_proofed_defs, :class_name => "EbyDef", :through => :eby_def_events, :conditions => "old_status = 'NeedProof1'", :source => :thedef
  has_many :second_proofed_defs, :class_name => "EbyDef", :through => :eby_def_events, :conditions => "old_status = 'NeedProof2'", :source => :thedef
  has_many :fixed_defs, :class_name => "EbyDef", :through => :eby_def_events, :conditions => "old_status = 'NeedFixup'", :source => :thedef

  validates :does_arabic, :does_extra, :does_greek, :does_russian, inclusion: { in: [true, false] }, allow_nil: true
  validates :role_fixer, :role_partitioner, :role_proofer, :role_publisher, :role_typist, inclusion: { in: [true, false] }, allow_nil: true
  validates :max_proof_level, numericality: true, allow_nil: true
  validates :password, presence: true, length: { minimum: 4 }
  validates :fullname, presence: true, length: { minimum: 3 }
  validates :email, presence: true, length: { minimum: 5 }
  validates_uniqueness_of :login, :on => :create, :message => I18n.t(:user_login_not_unique)
  validates_length_of :login, :within => 3..40, :message => I18n.t(:user_login_bad_length)
  validates_presence_of :login, :message => I18n.t(:user_login_cant_be_blank)

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
