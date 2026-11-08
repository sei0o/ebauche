class Tag < ApplicationRecord
  # aspect: 何がよいと思ったか（制限表の行と対応させる。出題に使う）
  # subject: 描かれている対象 / technique: 描いている手法
  enum :category, { aspect: 0, subject: 1, technique: 2 }

  has_many :taggings, dependent: :destroy
  has_many :refs, through: :taggings

  validates :name, presence: true, uniqueness: { scope: :category }

  default_scope { order(:category, :position, :name) }

  CATEGORY_LABELS = { "aspect" => "観点", "subject" => "対象", "technique" => "技法" }.freeze

  # 「対象:猫, 技法:厚塗り」や「猫 厚塗り」のような入力をタグにする。接頭辞がなければ対象扱い
  def self.from_text(text)
    text.to_s.tr("：，", ":,").split(/[,、\s]+/).filter_map do |token|
      category, name = token.include?(":") ? token.split(":", 2) : [ "対象", token ]
      key = CATEGORY_LABELS.key(category) || (categories.key?(category) ? category : nil)
      next if key.nil? || name.blank?
      find_or_create_by!(category: key, name: name.strip)
    end
  end
end
