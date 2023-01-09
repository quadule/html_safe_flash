# html_safe_flash
Use `html_safe` strings naturally in Rails flash messages.

## Usage
Just store any `html_safe` string in a flash message!

Since Rails 4.1+ (which switched to JSON as the default cookie serializer), code like this does not work as one might expect:

```ruby
class PostsController < ApplicationController
  def create
    @post.save!
    flash[:success] = "Done! Go view your #{link_to "post", @post}.".html_safe
    redirect_to :index
  end
end
```

Calling `html_safe` on the string returns a `ActiveSupport::SafeBuffer` object.
When Rails serializes it to the session cookie, this object is stored as a normal string, losing its `html_safe?` status when loaded on the next page. 

Some applications work around this issue by rendering every flash message with `html_safe` or `raw`.
This isn't always a problem, but can easily create a cross-site scripting security vulnerability if a message ever includes unescaped user input.

With this gem installed however, `flash[:success].html_safe?` will return true on the next request because html_safe metadata is tracked internally — `html_safe_flash` patches `ActionDispatch::Flash::FlashHash` to store something like this in the session:

```json
{
  "success": "Done! Go view your <a href='/posts/1'>post</a>.",
  "_html_safe_keys": ["success"]
}
```

On the next request, the message is automatically converted back to a `ActiveSupport::SafeBuffer` and the extra metadata is removed.

## Installation
Add this line to your application's Gemfile after `rails`:

```ruby
gem "html_safe_flash"
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
