require "test_helper"

class StudiesControllerTest < ActionDispatch::IntegrationTest
  setup { @ref = create_ref }

  test "uploading a drawing opens the comparison" do
    assert_difference("@ref.studies.count", 1) do
      post ref_studies_path(@ref), params: { study: { drawing: fixture_file_upload("sample.png", "image/png"), minutes: "30" } }
    end
    study = Study.last
    assert_equal 30, study.minutes
    assert_redirected_to study_path(study)

    follow_redirect!
    assert_select ".compare img[data-slic-target=image]", 2
    assert_select "input[data-slic-target=toggle]"
  end

  test "upload without a drawing goes back to the ref" do
    assert_no_difference("Study.count") do
      post ref_studies_path(@ref), params: { study: { minutes: "" } }
    end
    assert_redirected_to ref_path(@ref)
  end

  test "index and ref page list studies" do
    study = @ref.studies.create!(drawing: file_fixture_attachable)
    get studies_path
    assert_select "a[href='#{study_path(study)}']"
    get ref_path(@ref)
    assert_select "a[href='#{study_path(study)}']"
  end

  test "update saves the review memo" do
    study = @ref.studies.create!(drawing: file_fixture_attachable)
    patch study_path(study), params: { study: { memo: "明暗の幅が狭い" } }
    assert_equal "明暗の幅が狭い", study.reload.memo
  end

  test "destroy goes back to the ref" do
    study = @ref.studies.create!(drawing: file_fixture_attachable)
    assert_difference("Study.count", -1) { delete study_path(study) }
    assert_redirected_to ref_path(@ref)
  end
end
