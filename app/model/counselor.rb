class Counselor < ActiveRecord::Base
  include ConversationHelper

  has_attached_file :high_res_image, styles: {small: "315x291#"}

  belongs_to :user

  has_many :conversations, dependent: :destroy
  has_many :session_invitations, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :payouts, dependent: :destroy
  has_many :counselor_taggings, dependent: :destroy
  has_and_belongs_to_many :tags, join_table: 'counselor_taggings', class_name: 'CounselorTag'
  has_many :counselor_helping_categories, dependent: :destroy
  has_and_belongs_to_many :categories, join_table: 'counselor_helping_categories', class_name: 'HelpingCategory'
  has_many :external_users
  has_many :users, through: :external_users
  has_many :events_as_host, class_name: 'Event', dependent: :destroy
  has_many :workshop_counselors, dependent: :destroy
  has_many :workshops_as_participant, through: :workshop_counselors, source: :workshop
  has_many :client_prices
  has_and_belongs_to_many :languages

  validates_uniqueness_of :user_id, :url

  scope :first_by_id, -> { order('id ASC').limit(1).first }
  scope :last_by_id, -> { order('id DESC').limit(1).first }
  scope :available, -> { where('available = true') }
  scope :not_hidden_and_available, -> { where('hidden = false AND available = true') }
  scope :ordered_by_first_name, -> { joins(:user).order("lower(first_name) ASC") }
  scope :first_fours, -> { order('id DESC').limit(4) }

  delegate :email, to: :user

  def self.prepared_for_index_page
    emails = ['gdigiorgio@stillpointspaces.com', 'aocazionez@stillpointspaces.com', 'amonroytoro@stillpointspaces.com', 'vfagotto@stillpointspaces.com']
    Counselor.not_hidden_and_available.joins(:user).where.not("users.email IN (?)", emails)
  end

  def self.search(names)
    names.split(' ').map { |name| joins(:user).where("lower(users.first_name) like ? OR lower(users.last_name) like ? ", "%#{name.downcase}%", "%#{name.downcase}%")}
      .flatten.uniq
  end

  def self.filter(categories)
    available_counselors = Counselor.not_hidden_and_available
    return available_counselors if categories.empty?

    counselors = get_counselors_from_categories(categories)

    counselors.flatten!

    counselors.select! do |counselor|
      available_counselors.exists?(id: counselor.id)
    end

    counselors.uniq!

    counselors
  end

  def self.filter_by_language(languages)
    available_counselors = Counselor.not_hidden_and_available
    return available_counselors if languages.empty?

    counselors = get_counselors_from_languages(languages)

    counselors.flatten!

    counselors.select! do |counselor|
      available_counselors.exists?(id: counselor.id)
    end

    counselors.uniq!

    counselors
  end

  def has_toolbar?
    has_blog? || has_practice_address? || has_vimeo? || has_soundcloud?
  end

  def has_blog?
    !blog_url.nil? && !self.blog_url.empty?
  end

  def has_practice_address?
    !google_maps_url.nil? && !google_maps_url.empty?
  end

  def has_vimeo?
    !vimeo_url.nil? && !vimeo_url.empty?
  end

  def has_soundcloud?
    !soundcloud_url.nil? && !soundcloud_url.empty?
  end

  def self.prev_counselor(counselor)
    where("id < ?", counselor.id).not_hidden_and_available.order('id DESC').limit(1).first || not_hidden_and_available.last_by_id
  end

  def self.next_counselor(counselor)
    where("id > ?", counselor.id).not_hidden_and_available.order('id ASC').limit(1).first || not_hidden_and_available.first_by_id
  end

  acts_as_url :name

  def to_param
    url
  end

  def client_price_for(client)
    client_prices.where(user_id: client.id).first || client_prices.build(amount_in_cents: price_per_session_hour_in_cents, client: client)
  end

  def name
    # on creation the user might be nil before save
    user.try(:name) || ""
  end

  def first_name
    # on creation the user might be nil before save
    user.try(:first_name) || ""
  end

  def conversation_with(user)
    conversations.where(user_id: user.id).first || conversations.create(user_id: user.id)
  end

  def my_time_to_utc(time_string)
    ActiveSupport::TimeZone[user.timezone].parse(time_string).utc
  end

  def last_payout_date
    payouts.order('created_at ASC').last.try(:created_at)
  end

  def prev_counselor
    self.class.prev_counselor(self)
  end

  def next_counselor
    self.class.next_counselor(self)
  end

  def unread_messages_count(counselor)
    user = counselor.user
    ConversationHelper.unread_messages_count(conversations, user)
  end

  def conversations_with_unread_messages(counselor)
    user = counselor.user
    ConversationHelper.get_conversations_with_unread_messages(conversations, user)
  end

  def upcoming_workshops
    workshops = []
    workshops << self.events_as_host.upcoming
    workshops << self.user.events.upcoming
    workshops.flatten!
    workshops.sort! { |workshop1, workshop2| workshop1.start_time <=> workshop2.start_time }
  end

  def payment_session_invitations
    self.payments.where(type: 'PaymentSessionInvitation')
  end

  private

  def price_per_session_hour_in_cents
    price_per_session_hour * 100
  end

  def self.get_counselors_from_categories(categories)
    categories.map do |category|
        HelpingCategory.find(category).counselors
    end
  end

  def self.get_counselors_from_languages(languages)
    languages.map do |language|
        Language.find(language).counselors
    end
  end

end
