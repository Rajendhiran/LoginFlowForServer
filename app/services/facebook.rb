class Facebook
  attr_reader :access_token, :graph

  def initialize(access_token)
    @access_token = access_token
    @graph = Koala::Facebook::API.new(access_token)
  end

  def profile
    @profile ||= HashWithIndifferentAccess.new @graph.get_object("me")
  end

  def email
    profile[:email]
  end

  def id
    profile[:id]
  end

  def db_user_by_email
    User.find_by_email(email)
  end

  def db_user_by_id
    User.find_by_id(id)
  end

  class << self
    def authenticate(access_token)
      fb = new(access_token)

      profile = fb.profile rescue nil # nil if it's invalid token
      return nil unless profile.present?

      # find by id first
      user = fb.db_user_by_id

      # we don't have to do anything if user is found by id
      return user if user.present?

      # find by email
      user = fb.db_user_by_email

      if user.present?
        # user already existed, but he/she is not linked to facebook id
        # ned to update fid in to user
        user.update_column(:fid, fb.id)
      else
        # create new user with default facebook email and facebook id
        user = User.new(fid: fb.id, email: fb.email, password: SecureRandom.uuid)
        user.skip_confirmation!
        user.save!
      end

      # return user back
      user
    end
  end
end
