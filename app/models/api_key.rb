class ApiKey < ActiveRecord::Base
  validates :key, presence: true
  def self.generate_new_key
    ApiKey.create(key: Digest::SHA512::hexdigest(SecureRandom::urlsafe_base64))
  end
end
