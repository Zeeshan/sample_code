class Event < ActiveRecord::Base
	has_attached_file :image, styles: {small: "315x291#"}

	belongs_to :host_counselor, class_name: "Counselor", foreign_key: "counselor_id"
  belongs_to :course
  has_and_belongs_to_many :partner_counselors, join_table: 'workshop_counselors', class_name: 'Counselor'
  before_destroy { partner_counselors.clear }
  has_and_belongs_to_many :offers, join_table: 'offer_workshops', class_name: 'OfferPackage'
  has_many :offer_workshops, dependent: :destroy
  has_many :payments, through: :offer_workshops
  has_many :user_events, dependent: :destroy
  has_one :video_session, dependent: :destroy
  has_many :users, through: :user_events
  before_validation :set_end_time, on: [ :create, :update ]

  scope :time_for_first_notification, -> { where('start_time < ? AND start_time > ?', FIRST_NOTIFICATION.from_now, (FIRST_NOTIFICATION - 30.minutes).from_now) }
  scope :time_for_last_notification, -> { where('start_time < ? AND start_time > ?', LAST_NOTIFICATION.from_now, (LAST_NOTIFICATION - 30.minutes).from_now) }
  scope :upcoming, -> { where('end_time > ?', Time.current).order("start_time ASC") }
  scope :are_not_draft, -> { where('draft = false').order("start_time ASC") }
  scope :past, -> { where('end_time < ?', Time.current).order("start_time DESC") }
  scope :imminent, -> { upcoming.where('start_time < ?', Time.current + CANCELLATION_PERIOD) }

  CANCELLATION_PERIOD = 24.hours
  SESSION_DURATION = 90.minutes
  FIRST_NOTIFICATION = 12.hours
  LAST_NOTIFICATION = 4.hours

  def set_end_time
    self.end_time = start_time + SESSION_DURATION
  end

  def starts_soon?
    now = Time.current
    (start_time < FIRST_NOTIFICATION.from_now && now < end_time) && video_session
  end

  def is_past?
    end_time < Time.current
  end

end