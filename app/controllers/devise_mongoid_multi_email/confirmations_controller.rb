module DeviseMongoidMultiEmail
  class ConfirmationsController < Devise::ConfirmationsController
  	def show
  		self.resource = resource_class.confirm_by_token(params[:confirmation_token])
  		yield resource if block_given?

  		sign_in self.resource.user if self.resource.valid?

  		if resource.errors.empty?
  		  set_flash_message!(:notice, :confirmed)
  		  redirect_to signed_in_root_path(resource.user)
  		else
  		  respond_with_navigational(resource.user.errors, status: :unprocessable_entity){ render :new }
  		end
  	end

    def create
      self.resource = resource_class.send_confirmation_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        set_flash_message!(:notice, :confirmation_sent)
        respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
      else
        resource.errors.messages[:email] = resource.errors.messages[:unconfirmed_email]
        respond_with(resource)
      end
    end
  end
end
