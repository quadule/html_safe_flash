# frozen_string_literal: true

require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "html_safe_flash/railtie"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.action_dispatch.cookies_serializer = :json

    routes.append do
      controller "dummy/application" do
        get :set_flash
        get :show_flash
      end
    end
  end

  class ApplicationController < ActionController::Base
    def set_flash
      flash[:html] = "<em>Welcome!</em>".html_safe
      flash[:text] = "Welcome!"
      redirect_to "/show_flash"
    end

    def show_flash
      render inline: capture do
        flash.each { |key, value| tag.p(value, class: key) }
      end
    end
  end
end

Dummy::Application.initialize!
