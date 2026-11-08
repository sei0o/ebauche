require "test_helper"

class Api::RefsControllerTest < ActionDispatch::IntegrationTest
  setup { ENV["EBAUCHE_API_TOKEN"] = "secret" }
  teardown { ENV.delete("EBAUCHE_API_TOKEN") }

  test "rejects requests without the token" do
    post api_refs_path, params: { images: [ fixture_file_upload("sample.png", "image/png") ] }
    assert_response :unauthorized
  end

  test "creates refs with the token" do
    assert_difference("Ref.count", 1) do
      post api_refs_path,
        params: { image: fixture_file_upload("sample.png", "image/png"), kind: "illust", memo: "線が細い" },
        headers: { "Authorization" => "Bearer secret" }
    end
    assert_response :created
    assert Ref.last.illust?
    assert_equal "線が細い", Ref.last.memo
  end

  test "invalid kind is a 422" do
    post api_refs_path,
      params: { image: fixture_file_upload("sample.png", "image/png"), kind: "video" },
      headers: { "Authorization" => "Bearer secret" }
    assert_response :unprocessable_entity
  end
end
