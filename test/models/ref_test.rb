require "test_helper"

class RefTest < ActiveSupport::TestCase
  test "requires an image" do
    ref = Ref.new
    assert_not ref.valid?
    assert ref.errors.of_kind?(:image, :blank)
  end

  test "rejects non-image files" do
    ref = Ref.new(image: { io: StringIO.new("hello"), filename: "a.txt", content_type: "text/plain" })
    assert_not ref.valid?
  end

  test "unannotated means no memo and no tags" do
    blank = create_ref
    with_memo = create_ref(memo: "影に青")
    with_tag = create_ref
    with_tag.tags << tags(:light)

    assert_equal [ blank ], Ref.unannotated.to_a
    assert with_memo.annotated?
    assert with_tag.annotated?
  end

  test "neighbors follow the given scope" do
    a, b, c = 3.times.map { create_ref }
    newer, older = b.neighbors_in(Ref.order(id: :desc))
    assert_equal c, newer
    assert_equal a, older
  end
end
