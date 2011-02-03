require 'custom_error_pages'

config.after_initialize do
  require 'application_helper'
  ::ApplicationHelper.send(:include, CustomErrorPages::Helper)

  require 'application_controller'
  ::ApplicationController.send(:include, CustomErrorPages::Controller)
end