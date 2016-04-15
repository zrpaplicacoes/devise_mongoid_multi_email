describe 'Recoverable confirmation', type: :feature do
	let(:user) { create(:user, :with_secondary_emails, amount_of_secondary_emails: 2) }
	let(:primary_email) { user.primary_email }
	let(:secondary_email) { user.secondary_emails.first }

	context 'when I visit the recover password page with a token' do

		context 'primary email confirmed' do

			before :each do
			  primary_email.confirm
			  expect(primary_email.confirmed?).to be_truthy
			  expect(primary_email.valid?).to be_truthy

			  reset_deliveries

			  @old_password = user.encrypted_password
				@token = user.send_reset_password_instructions email: primary_email.email_with_indiferent_access
				visit edit_user_password_path(reset_password_token: @token)

				fill_in 'user[password]', with: "newpassword@123"
				fill_in 'user[password_confirmation]', with: "newpassword@123"

				click_button 'Change my password'
			end

			it 'sends the email' do
				expect(deliveries_size).to eq 1
				expect(deliveries[0].subject).to eq 'Reset password instructions'
			end

			it 'saves the new password in the database' do
				user.reload
				new_password = user.encrypted_password
				expect(@old_password).to_not eq new_password
			end

			it 'redirect and sign up the user to the root path' do
				expect(current_path).to eq '/'
			end

			it 'display a success message' do
				expect(page).to have_content "Your password has been changed successfully. You are now signed in."
			end

		end

		context 'primary email unconfirmed' do

			before :each do
			  expect(primary_email.confirmed?).to be_falsy

			  reset_deliveries

			  @old_password = user.encrypted_password
				@token = user.send_reset_password_instructions email: primary_email.email_with_indiferent_access
				visit edit_user_password_path(reset_password_token: @token)

				fill_in 'user[password]', with: "newpassword@123"
				fill_in 'user[password_confirmation]', with: "newpassword@123"

				click_button 'Change my password'
			end

			it 'does not send the email' do
				expect(deliveries_size).to eq 0
			end

			it 'sets the token to false' do
				expect(@token).to eq false
			end

			it 'does not change the user password with an invalid token' do
				user.reload
				new_password = user.encrypted_password
				expect(@old_password).to eq new_password
			end

			it 'renders the page again' do
				expect(current_path).to eq '/users/password'
			end

			it 'displays an error message' do
				expect(page).to have_content "Reset password token is invalid"
			end

		end


		context 'secondary email confirmed with primary unconfirmed' do
			before :each do
				secondary_email.confirm

			  expect(primary_email.confirmed?).to be_falsy
			  expect(secondary_email.confirmed?).to be_truthy

			  reset_deliveries

			  @old_password = user.encrypted_password
				@token = user.send_reset_password_instructions email: secondary_email.email_with_indiferent_access
				visit edit_user_password_path(reset_password_token: @token)

				fill_in 'user[password]', with: "newpassword@123"
				fill_in 'user[password_confirmation]', with: "newpassword@123"

				click_button 'Change my password'
			end

			it 'does not send the email' do
				expect(deliveries_size).to eq 0
			end

			it 'sets the token to false' do
				expect(@token).to eq false
			end

			it 'does not change the user password with an invalid token' do
				user.reload
				new_password = user.encrypted_password
				expect(@old_password).to eq new_password
			end

			it 'renders the page again' do
				expect(current_path).to eq '/users/password'
			end

			it 'displays an error message' do
				expect(page).to have_content "Reset password token is invalid"
			end

		end

		context 'secondary email confirmed with primary confirmed' do
			before :each do
			  primary_email.confirm
			  secondary_email.confirm
			  expect(primary_email.confirmed?).to be_truthy
			  expect(secondary_email.confirmed?).to be_truthy

			  reset_deliveries

			  @old_password = user.encrypted_password
				@token = user.send_reset_password_instructions email: secondary_email.email_with_indiferent_access
				visit edit_user_password_path(reset_password_token: @token)

				fill_in 'user[password]', with: "newpassword@123"
				fill_in 'user[password_confirmation]', with: "newpassword@123"

				click_button 'Change my password'
			end

			it 'sends the email' do
				expect(deliveries_size).to eq 1
				expect(deliveries[0].subject).to eq 'Reset password instructions'
			end

			it 'saves the new password in the database' do
				user.reload
				new_password = user.encrypted_password
				expect(@old_password).to_not eq new_password
			end

			it 'redirect and sign up the user to the root path' do
				expect(current_path).to eq '/'
			end

			it 'display a success message' do
				expect(page).to have_content "Your password has been changed successfully. You are now signed in."
			end
		end


	end

end