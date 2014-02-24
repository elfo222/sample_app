class User < ActiveRecord::Base
	before_save		{ email.downcase! }
	before_create	:create_remember_token

	# Validate Name
	validates :name, presence: true, length: { minimum: 3, maximum: 50 }
	# Regex for email
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	# Validate Email
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
		uniqueness: { case_sensitive: false }
	# Validate Password
	validates :password, length: { minimum: 6 }

	# Password Support
	has_secure_password

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private
		
		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end
end
