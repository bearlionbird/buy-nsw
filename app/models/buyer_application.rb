require 'securerandom'

class BuyerApplication < ApplicationRecord
  include AASM

  belongs_to :assigned_to, class_name: 'User', optional: true
  belongs_to :buyer
  has_one :user, through: :buyer

  aasm column: :state do
    state :created, initial: true
    state :awaiting_manager_approval
    state :awaiting_assignment
    state :assigned
    state :approved
    state :rejected

    event :submit do
      transitions from: :created, to: :approved, guard: :no_approval_required?
      transitions from: :created, to: :awaiting_manager_approval, guard: :requires_manager_approval?

      transitions from: :created, to: :awaiting_assignment, guard: [:requires_email_approval?, :unassigned?]
      transitions from: :created, to: :assigned, guard: [:requires_email_approval?, :assignee_present?]

      before do
        self.submitted_at = Time.now
      end
    end

    event :manager_approve do
      transitions from: :awaiting_manager_approval, to: :awaiting_assignment, guard: [:requires_email_approval?, :unassigned?]
      transitions from: :awaiting_manager_approval, to: :assigned, guard: [:requires_email_approval?, :assignee_present?]
      transitions from: :awaiting_manager_approval, to: :approved
    end

    event :assign do
      transitions from: :awaiting_assignment, to: :assigned
    end

    event :approve do
      transitions from: :assigned, to: :approved
    end

    event :reject do
      transitions from: :assigned, to: :rejected
    end
  end

  def requires_email_approval?
    # NOTE: Don't require approval for emails which are at *.nsw.gov.au
    #
    !(user.email =~ /.*\.nsw\.gov\.au\Z$/)
  end

  def no_approval_required?
    !requires_email_approval? && !requires_manager_approval?
  end

  def requires_manager_approval?
    buyer.employment_status == 'contractor'
  end

  def assignee_present?
    assigned_to.present?
  end

  def unassigned?
    ! assignee_present?
  end

  def self.find_by_user_and_application(user_id, application_id)
    joins(:buyer).where(
      'buyers.user_id' => user_id,
      'buyer_applications.id' => application_id,
    ).first!
  end

  def set_manager_approval_token!
    update_attribute(:manager_approval_token, SecureRandom.hex(16))
  end

  scope :in_state, ->(state) { where('state = ?', state) }
  scope :assigned_to, ->(user) { where('assigned_to_id = ?', user) }
end
