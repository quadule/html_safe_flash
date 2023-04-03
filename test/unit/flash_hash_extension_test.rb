require "test_helper"

class FlashHashExtensionTest < ActiveSupport::TestCase
  test "enables handling of html_safe strings by default" do
    assert ActionDispatch::Flash::FlashHash.new.is_a?(HtmlSafeFlash::FlashHashExtension)
  end

  test "deserializes html_safe strings and arrays" do
    flash = ActionDispatch::Flash::FlashHash.from_session_value(
      "discard" => [],
      "flashes" => {
        "html" => "<em>one</em>",
        "more" => ["<p>one</p>".html_safe, "<p>two</p>".html_safe],
        "text" => "two",
        "_html_safe_keys" => ["html", "more"]
      }
    )
    assert_equal(
      {
        "html" => "<em>one</em>",
        "more" => ["<p>one</p>", "<p>two</p>"],
        "text" => "two"
      },
      flash.to_hash
    )
    assert flash[:html].html_safe?
    assert flash[:more][0].html_safe?
    assert flash[:more][1].html_safe?
    refute flash[:text].html_safe?
  end

  test "serializes html_safe strings and arrays" do
    flash = ActionDispatch::Flash::FlashHash.new(
      {
        "html" => "<em>one</em>".html_safe,
        "more" => ["<p>one</p>".html_safe, "<p>two</p>".html_safe],
        "text" => "two",
        "old" => "other".html_safe
      },
      ["old"]
    )
    assert_equal({
      "discard" => [],
      "flashes" => {
        "html" => "<em>one</em>",
        "more" => ["<p>one</p>", "<p>two</p>"],
        "text" => "two",
        "_html_safe_keys" => ["html", "more"]
      }
    }, flash.to_session_value)
  end
end
