require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates with normalized email" do
    assert_equal users(:me), User.authenticate_by(email_address: " ME@example.com ", password: "password")
    assert_nil User.authenticate_by(email_address: "me@example.com", password: "wrong")
  end
end
