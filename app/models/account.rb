require 'digest/sha1'
class Account < ActiveRecord::Base
	
	validates_presence_of :name
	#account name should be unique.
	validates_uniqueness_of :name
	
	attr_accessor :password_confirmation
	validates_confirmation_of :password
	
	def validate
		errors.add_to_base ("Missing password") if hashed_password.blank?
	end
	
	def self.authenticate(name, password)
		account = self.find_by_name(name)
		if account
			expected_password = encrypted_password(password, account.salt)
			if account.hashed_password != expected_password
				account = nil
				end
		end
		account
	end
	
	# 'password' is a virtual attribute
	def password
		@password
	end
	
	def password=(pwd)
		@password = pwd
		create_new_salt
		self.hashed_password = Account.encrypted_password(self.password, self.salt)
	end
	
	private
	
	def self.encrypted_password(password, salt)
		# 'wibble' makes it harder to guess
		string_to_hash = password + "wibble" + salt
		Digest::SHA1.hexdigest(string_to_hash)
	end
	
	def create_new_salt
		self.salt = self.object_id.to_s + rand.to_s
	end
end
