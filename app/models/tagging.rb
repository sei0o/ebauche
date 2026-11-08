class Tagging < ApplicationRecord
  belongs_to :ref
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :ref_id }
end
