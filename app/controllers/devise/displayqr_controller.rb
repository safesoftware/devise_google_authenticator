class Devise::DisplayqrController < DeviseController
  prepend_before_action :authenticate_scope!, :only => [:show,:update]

  include Devise::Controllers::Helpers

  def show
    if resource.nil? || resource.gauth_secret.nil?
      sign_in scope, resource, :bypass => true
      redirect_to stored_location_for(scope) || :root
    else
      render :show
    end
  end

  def update
    if resource.set_gauth_enabled(resource_params)
      set_flash_message :notice, :status
      sign_in scope, resource, :bypass => true
      redirect_to stored_location_for(scope) || :root
    else
      render :show
    end
  end

  def translation_scope
    'devise.displayqr'
  end

  private
  def scope
    resource_name.to_sym
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!")
    self.resource = send("current_#{resource_name}")
  end

  def resource_params
    params.require(resource_name.to_sym).permit(:gauth_enabled)
  end
end