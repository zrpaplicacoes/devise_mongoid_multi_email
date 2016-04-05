describe 'database authentication', type: :feature do
	let(:user) { create(:user, :with_secondary_emails, amount_of_secondary_emails: 2) }
	let(:primary_email) { user.primary_email }
	let(:secondary_emails) { user.secondary_emails }

	before :each do
		visit new_user_session_path
	end

	context 'if the email that I try to use to sign in is a primary email' do

		context 'if the email is confirmed' do
			before :each do
				fill_login_form_with email: user.email, password: user.password
				primary_email.confirm
				click_button 'Log in'
			end

			it 'allows the user to sign in' do
				expect(current_path).to eq root_path
				expect(page).to have_css '.cpy-signed-in'
				expect(page).to have_content 'Signed in successfully'
			end

		end

		context 'if the email is unconfirmed but a secondary email is confirmed' do

			before :each do

				expect(primary_email.confirmed?).to be_falsy
				secondary_emails.map { |email| email.confirm }

				secondary_emails.each do |email|
					expect(email.confirmed?).to be_truthy
				end

				fill_login_form_with email: user.email, password: user.password
				click_button 'Log in'
			end

			it 'does not allow the user to sign in' do
				expect(current_path).to eq '/users/sign_in'
				expect(page).to have_css '.cpy-signed-out'
			end

			it 'display an error message of confirm primary email address (devise.failure.unconfirmed) ' do
				expect(page).to have_content 'You have to confirm your email address before continuing'
			end

		end

		context 'if the email is unconfirmed and no secondary email is confirmed' do
			before :each do
				fill_login_form_with email: user.email, password: user.password
				click_button 'Log in'
			end

			it 'do not allow the user to sign in' do
				expect(current_path).to eq '/users/sign_in'
				expect(page).to have_css '.cpy-signed-out'
			end

			it 'displays an error message of access revoked (devise.failure.access_revoked)' do
				expect(page).to have_content 'The access to this account was revoked because it was not confirmed at all or does not exist anymore'
			end

		end

	end


	context 'if the email that I try to use to sign in is a secondary email' do

		before :each do
			@email_instance = secondary_emails.first
			secondary_emails.each do |email|
				expect(email.confirmed?).to be_falsy
			end
		end

		context 'if the email is confirmed' do
			before :each do
				@email_instance.confirm
				expect(@email_instance.confirmed?).to be_truthy
			end

			context 'if the primary email is confirmed' do
				before :each do
					primary_email.confirm
					expect(primary_email.confirmed?).to be_truthy
				end

				it 'allow the user to login with the secondary email' do
					fill_login_form_with email: @email_instance.email, password: user.password
					click_button 'Log in'
					expect(current_path).to eq '/'
					expect(page).to have_css '.cpy-signed-in'
				end

			end

			context 'if the primary email is unconfirmed' do
				before :each do
					expect(primary_email.confirmed?).to be_falsy
					fill_login_form_with email: @email_instance.email, password: user.password
					click_button 'Log in'
				end

				it 'does not allow the user to login' do
					expect(current_path).to eq '/users/sign_in'
					expect(page).to have_css '.cpy-signed-out'
				end

			end

		end

		context 'if the email is unconfirmed' do

			context 'if the primary email is confirmed' do
				before :each do
					primary_email.confirm
					expect(primary_email.confirmed?).to be_truthy
					fill_login_form_with email: @email_instance.email, password: user.password
					click_button 'Log in'
				end

				it 'does not allow the user to login' do
					expect(current_path).to eq '/users/sign_in'
					expect(page).to have_css '.cpy-signed-out'
				end


			end

			context 'if the primary email is unconfirmed' do
				before :each do
					expect(primary_email.confirmed?).to be_falsy
					fill_login_form_with email: @email_instance.email, password: user.password
					click_button 'Log in'
				end

				it 'does not allow the user to login' do
					expect(current_path).to eq '/users/sign_in'
					expect(page).to have_css '.cpy-signed-out'
				end
			end


		end


	end



end