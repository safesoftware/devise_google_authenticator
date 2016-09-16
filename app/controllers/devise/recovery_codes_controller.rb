class Devise::RecoveryCodesController < DeviseController
  prepend_before_filter :authenticate_scope!, except: [:verify_code]
  prepend_before_filter :devise_resource, :only => [:login]
  include Devise::Controllers::Helpers

  def index
    if resource.nil?
      redirect_to stored_location_for(scope) || :root
    end
  end

  def download
    if  resource.valid_password?(resource_params[:current_password])
      @unencrypted_codes = resource.create_recovery_codes
      send_data(@unencrypted_codes.join("\n"),
                type: 'text/plain; charset=utf-8',
                disposition: 'attachment; filename=fmecloud_recovery_codes.txt')
    else
      resource.errors.add(:current_password, resource_params[:current_password].blank? ? :blank : :invalid)
      render :index, status: 401
    end
  end

  def login
    @tmpid = resource_params[:tmpid]
  end

  def verify_code
    resource = resource_class.find_by(gauth_tmp: resource_params[:tmpid])
    if not resource.nil?

      if resource.valid_recovery_code?(resource_params[:gauth_recovery_code])
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(resource_name, resource)
        # remove used code
        resource.gauth_recovery_codes.delete(resource_params[:gauth_recovery_code])
        resource.save
        respond_with resource, :location => after_sign_in_path_for(resource)
      else
        set_flash_message(:error, :error)
        redirect_to :root
      end

    else
      set_flash_message(:error, :error)
      redirect_to :root
    end
  end

  def translation_scope
    'devise.recovery_codes'
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
    params.require(resource_name.to_sym).permit(:email, :gauth_recovery_code, :tmpid, :current_password)
  end

  def devise_resource
    self.resource = resource_class.new
  end

end