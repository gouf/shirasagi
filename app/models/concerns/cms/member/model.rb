module Cms::Member::Model
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site
  include Cms::Permission

  attr_accessor :in_password

  included do
    store_in collection: "cms_members"

    index({ email: 1 }, { unique: true, sparse: true })

    set_permission_name :cms_users, :edit

    seqid :id
    field :name, type: String
    field :email, type: String, metadata: { form: :email }
    field :password, type: String
    field :oauth_type, type: String
    field :oauth_id, type: String
    field :oauth_token, type: String
    field :last_loggedin, type: DateTime

    permit_params :name, :email, :password, :in_password

    validates :name, presence: true, length: { maximum: 40 }

    validates :email, email: true, length: { maximum: 80 }
    validates :email, uniqueness: { scope: :site_id }, presence: true, if: ->{ oauth_type.blank? }
    validates :password, presence: true, if: ->{ oauth_type.blank? }

    before_validation :encrypt_password, if: ->{ in_password.present? }
    before_validation :normalize_email
  end

  public
    def encrypt_password
      self.password = SS::Crypt.crypt(in_password)
    end

  private
    def normalize_email
      self.email = email.strip if email.present?
      if email.blank? && has_attribute?(:email)
        remove_attribute(:email)
      end
    end
end
