class User
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :domain_name, :email
  validates :email, format: { with: /\A[\w._-]+[+]?[\w._-]+@[\w.-]+\.[a-zA-Z]{2,6}\z/}

  def initialize(info)
    @email = info[:email]
    @domain_name = info[:domain_name]
    @random_number = SecureRandom.random_number(100).to_s
  end

  def valid_email
    @email.gsub(/@/, '&&&&') + '@student.nextacademy.com'
  end

  def valid_domain_name
    username + '.nextqd.com'
  end

  def username
    @domain_name + @random_number
  end
end