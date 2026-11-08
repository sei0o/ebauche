require "test_helper"

class RefsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "index lists refs and filters by shelf" do
    photo = create_ref(kind: :photo)
    illust = create_ref(kind: :illust)

    get refs_path(kind: "illust")
    assert_response :success
    assert_select "a[href^='#{ref_path(illust)}']"
    assert_select "a[href^='#{ref_path(photo)}']", count: 0
  end

  test "uploading several images creates one ref each" do
    assert_difference("Ref.count", 2) do
      post refs_path, params: {
        kind: "illust",
        images: [ fixture_file_upload("sample.png", "image/png"), fixture_file_upload("sample.png", "image/png") ]
      }
    end
    assert Ref.last.illust?
    assert_redirected_to ref_path(Ref.order(:id).last(2).first, filter: "unannotated")
  end

  test "upload without images goes back" do
    assert_no_difference("Ref.count") { post refs_path, params: { kind: "photo" } }
    assert_redirected_to new_ref_path
  end

  test "update sets aspects, free tags and memo" do
    ref = create_ref
    patch ref_path(ref), params: { ref: {
      aspect_ids: [ "", tags(:light).id ], drawable: "cannot", memo: "縁だけ彩度が高い", free_tags: "猫 技法:厚塗り"
    } }

    ref.reload
    assert ref.drawable_cannot?
    assert_equal "縁だけ彩度が高い", ref.memo
    assert_equal %w[光 厚塗り 猫].sort, ref.tags.map(&:name).sort
  end

  test "save and next jumps to the next unannotated ref" do
    first, second = create_ref, create_ref
    patch ref_path(first), params: { ref: { memo: "x" }, commit_next: "1" }
    follow_redirect!
    assert_redirected_to ref_path(second, filter: "unannotated")
  end

  test "destroy removes the ref" do
    ref = create_ref
    assert_difference("Ref.count", -1) { delete ref_path(ref) }
  end
end
