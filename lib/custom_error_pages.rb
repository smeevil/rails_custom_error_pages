class ApplicationController < ActionController::Base
  public
  
  def render_error(exception)
    log_error(exception) if respond_to?(:log_error)
    notify_hoptoad(exception) if respond_to?(:notify_hoptoad)
    activate_authlogic if respond_to?(:activate_authlogic)
    render :template => "/application/500", :status => 500, :layout=>"custom_error_page"
  end

  #keep this public for error calling from outside
  def render_not_found(exception=nil)
    if exception === Exception
      log_error(exception) if respond_to?(:log_error)
      notify_hoptoad(exception) if respond_to?(:notify_hoptoad)
    else
      @message = exception
    end
    render :template => "/application/404", :status => 404, :layout=>"custom_error_page"
  end
  
  private
  
  def handle_exceptions(exception)
    if defined?(Acl9)
      case exception
      when Acl9::AccessDenied
        access_denied(exception)
      else
        raise if ActionController::Base.consider_all_requests_local
      end
    else
      raise if ActionController::Base.consider_all_requests_local
    end
    
    # Only rescue these errors in production mode and when we have not yet performed a rendering.
    return if performed?

    case exception
    when ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownController, ActionController::UnknownAction
      render_not_found(exception) unless ActionController::Base.consider_all_requests_local
    else # Exception
      render_error(exception) unless ActionController::Base.consider_all_requests_local
    end
  end
  
  def access_denied(exception=nil)
    if current_user
      render :template => 'application/403', :layout=>"custom_error_page" , :status=>403
    else
      flash[:notice] = "Access denied. Try to log in first."
      redirect_to login_path
    end
  end
end

module ApplicationHelper
  def random_exception_image(err)
    files=Dir.glob("#{RAILS_ROOT}/public/images/#{err.to_s}/*")
    files.rand.gsub("#{RAILS_ROOT}/public/images/","")
  end
end