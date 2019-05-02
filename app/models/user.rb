class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships

  def stock_already_added?(ticker)
    stock = Stock.find_by_ticker(ticker)
    return false unless stock

    user_stocks.where(stock_id: stock.id).exists?
  end

  def under_stock_limit?
    (user_stocks.count < 10)
  end

  def can_add_stock?(ticker)
    under_stock_limit? && !stock_already_added?(ticker)
  end

  def full_name
    return "#{first_name} #{last_name}".strip if first_name || last_name

    'Anonymous'
  end

  def self.search(param)
    param.strip!
    param.downcase!
    response = (first_name_matches(param) + last_name_matches(param) + email_matches(param)).uniq
    return nil unless response

    response
  end

  def self.first_name_matches(param)
    matches('first_name', param)
  end

  def self.last_name_matches(param)
    matches('last_name', param)
  end

  def self.email_matches(param)
    matches('email', param)
  end

  def self.matches(field, param)
    where("#{field} like ?", "%#{param}%")
  end

  def except_current_user(users)
    users.reject { |user| user.id == id }
  end

  def already_friend?(friend_id)
    friendships.where(friend_id: friend_id).count > 0
  end
end
