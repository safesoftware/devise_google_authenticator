module DeviseGoogleAuthenticator
	module Generators
		class DeviseGoogleAuthenticatorGenerator < Rails::Generators::NamedBase

			namespace "devise_google_authenticator"

			desc "Add :google_authenticatable directive in the given model, plus accessors. Also generate migration for ActiveRecord"

			def inject_devise_google_authenticator_content
				path = File.join("app","models","#{file_path}.rb")

				if File.exists?(path)
				  inject_into_file(path, "google_authenticatable, :", :after => "devise :")
				  inject_into_class(path, class_name, "\tattr_accessor :gauth_token\n")
				  inject_into_class(path, class_name, "\tserialize :gauth_recovery_codes, Array\n")
				end
			end

			hook_for :orm

		end
	end
end