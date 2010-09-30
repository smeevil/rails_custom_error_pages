require 'custom_error_pages'

config.after_initialize do
  class ::ApplicationController < ActionController::Base
    include CustomErrorPages::Controller
  end

  module ApplicationHelper
    include CustomErrorPages::Helper
  end
end
