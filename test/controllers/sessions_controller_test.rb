require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "pages require login" do
    get refs_path
    assert_redirected_to new_session_path
  end

  test "login returns to the requested page and logout ends the session" do
    get ref_path(create_ref)
    post session_path, params: { email_address: "me@example.com", password: "password" }
    assert_redirected_to %r{/refs/\d+}

    delete session_path
    get refs_path
    assert_redirected_to new_session_path
  end

  test "wrong password goes back to the login page" do
    post session_path, params: { email_address: "me@example.com", password: "nope" }
    assert_redirected_to new_session_path
  end
end
