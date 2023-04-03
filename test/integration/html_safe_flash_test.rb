require "test_helper"

class HtmlSafeFlashTest < ActionDispatch::IntegrationTest
  test "transparently serializes and deserializes html_safe strings" do
    get "/set_flash"
    assert_equal ["html"], flash["_html_safe_keys"]
    follow_redirect!
    assert flash["html"].html_safe?
    refute flash["text"].html_safe?
    assert_nil flash["_html_safe_keys"]
  end
end
