class Order < ApplicationRecord
  before_create :generate_token
  belongs_to :user
  has_many   :product_lists

  validates :billing_name, presence: true
  validates :billing_address, presence: true
  validates :shipping_name, presence: true
  validates :shipping_address, presence: true

#设置token值
  def generate_token
    self.token = SecureRandom.uuid
  end

#更新数据库中支付方式
  def set_payment_with!(method)
    self.update_columns(payment_method: method)
  end

#更新支付状态
  def pay!
    self.update_columns(is_paid: true)
  end

#支付状态变更
  include AASM

  aasm do
    state :order_placed, initial: true
    state :paid
    state :shipping
    state :shipped
    state :order_cancelled
    state :good_returned

    #event :make_payment do
    event :make_payment, after_commit: :pay! do
      transitions from: :order_placed, to: :paid
    end

    event :ship do
      transitions from: :paid,          to: :shipped
    end

    event :deliver do
      transitions from: :shipping,      to: :shipped
    end

    event :return_good do
      transitions from: [:order_placed, :paid], to: :order_cancelled
    end

  end


end
