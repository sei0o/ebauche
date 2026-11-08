class Ref < ApplicationRecord
  # 棚。写真とイラストは別に並べる
  enum :kind, { photo: 0, illust: 1 }
  # 描けそうか。保存時の1タップ
  enum :drawable, { unknown: 0, can: 1, cannot: 2 }, prefix: true

  has_one_attached :image
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :studies, -> { order(created_at: :desc) }, dependent: :destroy

  validates :image, presence: true
  validate :image_must_be_image

  # 観点タグもメモもない＝まだ「なぜ良いか」を書いていない
  scope :unannotated, -> { where(memo: [ nil, "" ]).where.missing(:taggings) }
  scope :tagged_with, ->(tag) { joins(:taggings).where(taggings: { tag_id: tag }) }

  def annotated?
    memo.present? || taggings.any?
  end

  def neighbors_in(scope)
    newer = scope.where("refs.id > ?", id).reorder(id: :asc).first
    older = scope.where("refs.id < ?", id).reorder(id: :desc).first
    [ newer, older ]
  end

  private
    def image_must_be_image
      return unless image.attached?
      errors.add(:image, "は画像にしてください") unless image.content_type.to_s.start_with?("image/")
    end
end
