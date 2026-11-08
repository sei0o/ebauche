require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "from_text parses categories and reuses existing tags" do
    tags = Tag.from_text("猫 技法:厚塗り、対象：窓")
    assert_equal [ %w[subject 猫], %w[technique 厚塗り], %w[subject 窓] ], tags.map { |t| [ t.category, t.name ] }
    assert_no_difference("Tag.count") { Tag.from_text("猫") }
  end

  test "from_text ignores unknown categories" do
    assert_empty Tag.from_text("謎:なにか")
  end
end
