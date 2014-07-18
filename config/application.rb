require File.expand_path('../boot', __FILE__)
require 'rails/all'
require "attachinary/orm/active_record"

Bundler.require(:default, Rails.env)

module Grassroots
  class Application < Rails::Application
    config.time_zone = 'Central Time (US & Canada)'
    config.i18n.enforce_available_locales = true
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
