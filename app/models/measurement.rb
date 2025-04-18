class Measurement < ApplicationRecord
  belongs_to :member

  scope :between, ->(start_time:, end_time:) {
    order(tested_at: :desc).where("tested_at >= ?", start_time).where("tested_at <= ?", end_time)
  }
end
