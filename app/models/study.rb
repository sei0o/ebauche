class Study < ApplicationRecord
  belongs_to :ref
  has_one_attached :drawing

  validates :drawing, presence: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :drawing_must_be_image

  private
    def drawing_must_be_image
      return unless drawing.attached?
      errors.add(:drawing, "は画像にしてください") unless drawing.content_type.to_s.start_with?("image/")
    end
end
