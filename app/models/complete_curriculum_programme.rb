class CompleteCurriculumProgramme < ApplicationRecord
  validates :name, presence: true, length: { maximum: 256 }
  validates :rationale, presence: true

  has_many :units, dependent: :destroy

  # Stub implementation until we associate ccps with years
  def year
    'TODO!!'
  end
end
