require "test_helper"

class FlashHashExtensionTest < ActiveSupport::TestCase
  test "enables handling of html_safe strings by default" do
    assert ActionDispatch::Flash::FlashHash.handle_html_safe_flash
  end

  test "deserializes a html_safe string" do
    flash = ActionDispatch::Flash::FlashHash.from_session_value(
      "discard" => [],
      "flashes" => {"html" => "<em>one</em>", "text" => "two", "_html_safe_keys" => ["html"]}
    )
    assert_equal({"html" => "<em>one</em>", "text" => "two"}, flash.to_hash)
    assert flash[:html].html_safe?
    refute flash[:text].html_safe?
  end

  test "serializes a html_safe string" do
    flash = ActionDispatch::Flash::FlashHash.new(
      {"html" => "<em>one</em>".html_safe, "text" => "two", "old" => "other".html_safe},
      ["old"]
    )
    assert_equal({
      "discard" => [],
      "flashes" => {"html" => "<em>one</em>", "text" => "two", "_html_safe_keys" => ["html"]}
    }, flash.to_session_value)
  end

  test "does nothing when html_safe handling is disabled" do
    ActionDispatch::Flash::FlashHash.handle_html_safe_flash = false
    session_value = {
      "discard" => [],
      "flashes" => {"html" => "<em>one</em>", "text" => "two", "_html_safe_keys" => ["html"]}
    }
    flash = ActionDispatch::Flash::FlashHash.from_session_value(session_value)
    assert_equal session_value["flashes"], flash.to_hash
    refute flash[:html].html_safe?
    refute flash[:text].html_safe?
    flash.keep
    assert_equal session_value, flash.to_session_value
  ensure
    ActionDispatch::Flash::FlashHash.handle_html_safe_flash = true
  end
end
