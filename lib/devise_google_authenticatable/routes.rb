module ActionDispatch::Routing # :nodoc:
  class Mapper # :nodoc:

    protected

    # route for handle expired passwords
    def devise_displayqr(mapping, controllers)
      resource :displayqr, :only => [:show, :update], :path => mapping.path_names[:displayqr], :controller => controllers[:displayqr]
      resource :checkga, :only => [:show, :update], :path => mapping.path_names[:checkga], :controller => controllers[:checkga]
      resources :recovery_codes, :only => :index, :path => mapping.path_names[:recovery_codes], :controller => controllers[:recovery_codes] do
        collection do
          post :login, :verify_code, :download
        end
      end
    end

  end
end

