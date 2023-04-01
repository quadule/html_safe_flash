# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors_per_thread"

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
      safe_keys = @flashes.delete(HTML_SAFE_KEYS)
      safe_values = @flashes.slice(*safe_keys)
      safe_values.each do |key, value|
        @flashes[key] = html_safe_value_or_array(value)
      end
    end

    def serialize_html_safe_values
      safe_keys = @flashes.except(*@discard).filter_map do |key, value|
        key if html_safe_string?(value) || html_safe_array?(value)
      end

      if safe_keys.empty?
        @flashes.delete(HTML_SAFE_KEYS)
      else
        @flashes[HTML_SAFE_KEYS] = safe_keys
      end
    end

    def html_safe_value_or_array(value)
      if value.respond_to?(:html_safe)
        value.html_safe
      elsif value.is_a?(Array)
        value.map do |item|
          item.respond_to?(:html_safe) ? item.html_safe : item
        end
      else
        value
      end
    end

    def html_safe_array?(value)
      value.is_a?(Array) && value.any? && value.all?(&method(:html_safe_string?))
    end

    def html_safe_string?(value)
      value.is_a?(ActiveSupport::SafeBuffer) && value.html_safe?
    end
  end
end
