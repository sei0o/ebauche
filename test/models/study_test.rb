require "test_helper"

class StudyTest < ActiveSupport::TestCase
  test "requires a drawing" do
    study = create_ref.studies.new
    assert_not study.valid?
    assert study.errors.of_kind?(:drawing, :blank)
  end

  test "is destroyed with its ref" do
    ref = create_ref
    ref.studies.create!(drawing: file_fixture_attachable)
    assert_difference("Study.count", -1) { ref.destroy }
  end
end
