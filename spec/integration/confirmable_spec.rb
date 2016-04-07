describe 'Confirmable', type: :feature do
	context 'when I create or update a user' do
		before :each do
			reset_deliveries
		end

		it 'sets the primary email as the email passed on the creation' do
			user = User.create(email: "test@test.com", password: "zrp@12345")
			expect(user.primary_email).to_not be nil
			expect(user.primary_email).to be_persisted
			expect(user.email).to eq user.primary_email.email_with_indiferent_access
			expect(user.primary_email.email).to eq nil
			expect(user.primary_email.unconfirmed_email).to eq "test@test.com"
		end

		it 'sets all the created emails as unconfirmed' do
			user = User.create(email: "test@test.com", password: "zrp@12345")
			user.emails << create_list(:email, 3, :secondary, user: user)
			expect(user.emails.count).to eq 4
			user.emails.each do |email|
				expect(email.confirmed?).to be_falsy
				expect(email).to be_persisted
			end
		end

		it 'only allows one single primary email' do
			user = User.create(email: "test@test.com", password: "zrp@12345")
			expect { user.emails << create_list(:email, 3, primary: true, user: user) }.to raise_error
			expect(user.emails.count).to eq 1
		end

		it 'sends a confirmation email' do
			user = User.create(email: "test@test.com", password: "zrp@12345")
			expect(user.persisted?).to be_truthy
			expect(deliveries_size).to eq 1
			expect(deliveries[0].subject).to eq "Confirmation instructions"
		end

		it 'sends an email for each email entry of the user' do
			user = User.create(email: "test@test.com", password: "zrp@12345")
			user.emails << create_list(:email, 3, :secondary, user: user)
			expect(deliveries_size).to eq 4
			user.emails << create_list(:email, 2, :secondary, user: user)
			expect(deliveries_size).to eq 6
		end

	end

	context 'when I try to confirm an user email' do
		let(:user) { create(:user, :with_secondary_emails, amount_of_secondary_emails: 2) }
		let(:primary_email) { user.primary_email }
		let(:secondary_email) { user.secondary_emails.first }

		context 'if the email is a primary email' do
			before :each do
				expect(primary_email.confirmed?).to be_falsy
				expect(primary_email.unconfirmed_email.blank?).to be_falsy
				@token = primary_email.send_confirmation_instructions
				visit user_confirmation_url(confirmation_token: @token)
			end

			it 'redirects the user back to the sign in page' do
				expect(current_path).to eq '/users/sign_in'
			end

			it 'shows a succesfully confirmed message' do
				expect(page).to have_content "Your email address has been successfully confirmed."
			end

			it 'confirms the passed email' do
				primary_email.reload
				expect(primary_email.confirmed?).to be_truthy
			end

			it 'does not confirm any other email' do
				user.reload
				user.secondary_emails.each do |record|
					expect(record.confirmed?).to be_falsy
				end
			end

			it 'makes the user account active and confirmed' do
				user.reload
				expect(user.confirmed?).to be_truthy
				expect(user.account_active?).to be_truthy
			end
		end

		context 'if the email is a secondary email' do
			before :each do
				expect(secondary_email.confirmed?).to be_falsy
				expect(secondary_email.unconfirmed_email.blank?).to be_falsy
				@token = secondary_email.send_confirmation_instructions
				visit user_confirmation_url(confirmation_token: @token)
			end

			it 'redirects the user back to the sign in page' do
				expect(current_path).to eq '/users/sign_in'
			end

			it 'shows a succesfully confirmed message' do
				expect(page).to have_content "Your email address has been successfully confirmed."
			end

			it 'confirms the passed email' do
				secondary_email.reload
				expect(secondary_email.confirmed?).to be_truthy
			end

			it 'does not confirm any other email' do
				user.reload
				(user.emails - Array(secondary_email)).each do |record|
					expect(record.confirmed?).to be_falsy
				end
			end

			it 'makes the user account active but not confirmed' do
				user.reload
				expect(user.confirmed?).to be_falsy
				expect(user.account_active?).to be_truthy
			end
		end

		context 'if the confirmation token is invalid' do
			before :each do
				visit user_confirmation_url(confirmation_token: "#{SecureRandom.base64}")
			end

			it 'renders the page again' do
				expect(current_path).to eq '/users/confirmation'
			end

			it 'shows an error message' do
				expect(page).to have_content "Confirmation token is invalid"
			end

			it 'does not create an email' do
				current_email_count = UserEmail.count
				expect(current_email_count).to eq 0
			end
		end

	end

	context 'when I try to request a new confirmation token' do
		let(:user) { create(:user, :with_secondary_emails, amount_of_secondary_emails: 2)}
		let(:primary_email) { user.primary_email }
		let(:secondary_email) { user.secondary_emails.first }

		before :each do
			visit new_user_confirmation_path
		end

		context 'when the email is a primary email' do
			before :each do
				fill_in 'Email', with: primary_email.email_with_indiferent_access
				reset_deliveries
				click_button 'Resend confirmation instructions'
			end

			it 'shows a successfull sent message' do
				expect(page).to have_content 'You will receive an email with instructions for how to confirm your email address in a few minutes.'
			end

			it 'redirects the user to the sign in page' do
				expect(current_path).to eq '/users/sign_in'
			end

			it 'resends the confirmation email' do
				expect(deliveries_size).to eq 1
				expect(deliveries[0].subject).to eq 'Confirmation instructions'
				expect(deliveries[0].to).to eq primary_email.email_with_indiferent_access
			end

		end

		context 'when the email is a secondary email' do
			before :each do
				reset_deliveries
				fill_in 'Email', with: secondary_email.email_with_indiferent_access
				click_button 'Resend confirmation instructions'
			end

			it 'shows a successfull sent message' do
				expect(page).to have_content 'You will receive an email with instructions for how to confirm your email address in a few minutes.'
			end

			it 'redirects the user to the sign in page' do
				expect(current_path).to eq '/users/sign_in'
			end

			it 'resends the confirmation email' do
				expect(deliveries_size).to eq 1
				expect(deliveries[0].subject).to eq 'Confirmation instructions'
				expect(deliveries[0].to).to eq secondary_email.email_with_indiferent_access
			end
		end

		context 'when the email does not exist' do
			before :each do
				fill_in 'Email', with: "invalid_email@test.com"
				click_button 'Resend confirmation instructions'
			end

			it 'shows an error message' do
				expect(page).to have_content 'invalid token'
			end
		end

	end


end