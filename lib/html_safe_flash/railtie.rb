# frozen_string_literal: true

module HtmlSafeFlash
  class Railtie < ::Rails::Railtie
    initializer "html_safe_flash.extend_flash_hash" do
      ActiveSupport.on_load(:action_controller) do
        ActionDispatch::Flash::FlashHash.prepend(FlashHashExtension)
      end
    end
  end
end
