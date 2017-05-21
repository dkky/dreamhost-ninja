class User
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :domain_name
  attr_accessor :email
  validates :email, format: { with: /\A[\w._-]+[+]?[\w._-]+@[\w.-]+\.[a-zA-Z]{2,6}\z/}

  def initialize(info)
    @email = info[:email]
    @domain_name = info[:domain_name]
  end

  def valid_email
    @email.gsub(/@/, '&&&&') + '@student.nextacademy.com'
  end
end