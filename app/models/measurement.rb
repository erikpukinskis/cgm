class Measurement < ApplicationRecord
  belongs_to :member

  scope :recent, -> { order(tested_at: :desc).where("tested_at > ?", 1.month.ago) }
end
