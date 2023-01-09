# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors_per_thread"
require "active_support/core_ext/object/try"

module HtmlSafeFlash
  module FlashHashExtension
    extend ActiveSupport::Concern

    prepended do
      thread_mattr_accessor :handle_html_safe_flash, instance_writer: false, default: true
    end

    class_methods do
      def from_session_value(*)
        super.tap do |flash|
          flash.send(:deserialize_html_safe_values) if handle_html_safe_flash
        end
      end
    end

    def to_session_value
      serialize_html_safe_values if handle_html_safe_flash
      super
    end

    private

    HTML_SAFE_KEYS = "_html_safe_keys"

    def deserialize_html_safe_values
      Array.wrap(@flashes.delete(HTML_SAFE_KEYS)).each do |key|
        value = @flashes[key]
        if value.respond_to?(:html_safe)
          @flashes[key] = value.html_safe
        end
      end
    end

    def serialize_html_safe_values
      safe_keys = @flashes.except(*@discard).filter_map do |key, value|
        key if value.is_a?(ActiveSupport::SafeBuffer) && value.html_safe?
      end

      if safe_keys.empty?
        @flashes.delete(HTML_SAFE_KEYS)
      else
        @flashes[HTML_SAFE_KEYS] = safe_keys
      end
    end
  end
end
