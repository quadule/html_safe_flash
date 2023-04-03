# html_safe_flash
Use `html_safe` strings naturally in Rails flash messages.

## Installation
Add this line to your application's Gemfile anywhere after `rails`:

```ruby
gem "html_safe_flash"
```

## Usage
Store any `html_safe` string (or an array of them) in the Rails `flash` object:

```ruby
class PostsController < ApplicationController
  def create
    @post.save!
    flash[:success] = "Done! Go view your #{link_to "post", @post}.".html_safe
    redirect_to :index
  end
end
```

This gem patches `ActionDispatch::Flash::FlashHash` to track any `html_safe` values internally.
In the example above, this is the actual flash data stored in the session cookie:

```json
{
  "success": "Done! Go view your <a href='/posts/1'>post</a>.",
  "_html_safe_keys": ["success"]
}
```

On the next request, the `_html_safe_keys` metadata is removed and the `success` message is converted back to an `ActiveSupport::SafeBuffer` automatically.

Without this gem, the code above would not work as one might expect:
Calling `html_safe` on the message returns a `ActiveSupport::SafeBuffer` object, which becomes a normal string when Rails stores it in the session cookie.
When the cookie is loaded on the next page, the `html_safe?` state of the message would be lost.

## Why?

Using `html_safe` like this was possible in old versions of Rails, which serialized cookies using `Marshal`, allowing arbitrary objects like `ActiveSupport::SafeBuffer` to be stored.
In Rails 4.1 this was changed for security reasons, and cookie data is limited to the basic types supported by the default `JSON` serializer.

Without a way to store `html_safe` values, some applications work around the issue by rendering every flash message with `html_safe` or `raw`. This can become a cross-site scripting security vulnerability if a message ever includes unescaped user input.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
