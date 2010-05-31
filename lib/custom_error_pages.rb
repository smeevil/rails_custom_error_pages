module CustomErrorPages
  def self.included(klass)
    klass.extend ClassMethods
    klass.handle_exceptions
  end

  def render_error(exception=nil)
    logger.debug "Real error"
    if exception.kind_of?(Exception)
      logger.debug "Exception matched. Logging."
      log_error(exception)
      logger.debug "Notifying hoptoad"
      attempt_to_notify_hoptoad(exception)
      if respond_to?(:activate_authlogic)
        logger.debug "Activating authlogic"
        activate_authlogic
      end
    else
      logger.debug "Not an exception, treating it as custom message."
      @message = exception
    end
    respond_to do |format|
      format.html {render :template => "/application/500", :status => 500, :layout=>"custom_error_page"}
      format.xml {render :template => "/application/500", :status => 500}
    end
  end

  def access_denied(exception=nil)
    logger.debug "Access denied"
    @message = exception unless exception.kind_of?(Exception)
    if current_user
      flash[:error] = "Access denied. You have insufficient privileges to go here."
    else
      flash[:error] = "Access denied. Try to log in first."
    end
    respond_to do |format|
      format.html do
        if current_user
          render :template => 'application/403', :layout=>"custom_error_page" , :status=>403
        else
          redirect_to login_path
        end
      end
      format.xml {render :template => 'application/403', :status=>403}
    end
  end

  def render_not_found(exception=nil)
    logger.debug "Not found"
    if exception.kind_of? Exception
      log_error(exception)
      attempt_to_notify_hoptoad(exception)
    elsif exception.nil? && params[:path].is_a?(Array)
      # Catch-all route defined in routes.rb. Just render the 404.
    else
      @message = exception
    end
    respond_to do |format|
      format.html {render :template => "/application/404", :status => 404, :layout=>"custom_error_page"}
      format.xml {render :template => "/application/404", :status => 404}
    end

  end

  protected

  def handle_exception(exception)
    logger.debug "Handling exception: #{exception.class}"
    case exception
    when *self.class.access_denied_errors
      access_denied(exception)
    when *self.class.not_found_errors
      render_not_found(exception)
    when *self.class.real_errors
      render_error(exception)
    else
      logger.info "Unhandled exception. Calling super."
      super
    end
  rescue Exception => e
    logger.info "Error while handling errors: #{e.inspect}. Notifying hoptoad."
    attempt_to_notify_hoptoad(e)
    raise e
  end

  def attempt_to_notify_hoptoad(exception)
    if defined?(HoptoadNotifier::Rails::ControllerMethods) and self.class.included_modules.include?(HoptoadNotifier::Rails::ControllerMethods)
      logger.debug "Notify hoptoad by means of notify_hoptoad"
      notify_hoptoad(exception)
    elsif defined?(HoptoadNotifier) and HoptoadNotifier.respond_to?(:notify)
      logger.debug "Notify hoptoad by means of HoptoadNotifier.notify"
      HoptoadNotifier.notify(exception)
    else
      logger.debug "We have no way to notify Hoptoad. Is the hoptoad_notifier gem even installed?"
    end
  end

  module ClassMethods
    def handle_exceptions
      (access_denied_errors + not_found_errors + real_errors).each do |error|
        rescue_from error, :with => :handle_exception
      end
    end

    def access_denied_errors
      errors = []
      errors << ActionController::InvalidAuthenticityToken
      errors << Acl9::AccessDenied if defined?(Acl9::AccessDenied)
      errors
    end

    def not_found_errors
      errors = []
      errors << ActiveRecord::RecordNotFound if defined?(ActiveRecord::RecordNotFound) and not ActionController::Base.consider_all_requests_local
      errors << ActionController::RoutingError if defined?(ActionController::RoutingError) and not ActionController::Base.consider_all_requests_local
      errors << ActionController::UnknownController if defined?(ActionController::UnknownController) and not ActionController::Base.consider_all_requests_local
      errors << ActionController::UnknownAction if defined?(ActionController::UnknownAction) and not ActionController::Base.consider_all_requests_local
      errors
    end

    def real_errors
      errors = []
      errors << Exception if not ActionController::Base.consider_all_requests_local
      errors
    end
  end
end

module ApplicationHelper
  def random_exception_image(err)
    files=Dir.glob("#{RAILS_ROOT}/public/images/#{err.to_s}/*")
    # Rails 2.3.6 deprecates the old Array#rand in favor of Array#random_element.
    random_method = files.respond_to?(:random_element) ? :random_element : :rand
    files.send(random_method).gsub("#{RAILS_ROOT}/public/images/","")
  end
end

class ApplicationController < ActionController::Base
  include CustomErrorPages
end
