module RSpec
	module Support

		module UserForm

			def fill_login_form_with options
				fill_in 'Email', with: options[:email]
				fill_in 'Password', with: options[:password]
			end

			def click_reset_password_instructions_button
				click_button 'Send me reset password instructions'
			end

		end

	end
end