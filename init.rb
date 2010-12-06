require 'custom_error_pages'

config.after_initialize do
  ::ApplicationController.send(:include, CustomErrorPages::Controller)
  ::ApplicationHelper.send(:include, CustomErrorPages::Helper)
end
