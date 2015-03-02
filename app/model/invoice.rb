class Invoice < ActiveRecord::Base
  belongs_to :payment
  belongs_to :session_invitation
  validates_presence_of :payment_id, :session_invitation_id

  before_validation :set_session_invitation, on: :create

  def user
    payment.user
  end

  def counselor
    payment.counselor
  end

  def amount
    BigDecimal.new(amount_in_cents.to_s) / 100
  end

  def sender_address
    Address.new name: sender_name, street: sender_street,
      post_code: sender_post_code, city: sender_city,
      country: sender_country
  end

  def recipient_address
    Address.new name: recipient_name, street: recipient_street,
      post_code: recipient_post_code, city: recipient_city,
      country: recipient_country
  end

  class Address
    attr_reader :name, :street, :post_code, :city, :country

    def initialize(attributes)
      attributes.each do |name, value|
        instance_variable_set "@#{name}", value
      end
    end
  end

  protected
  def set_session_invitation
    self.session_invitation = payment.session_invitation
  end
end
