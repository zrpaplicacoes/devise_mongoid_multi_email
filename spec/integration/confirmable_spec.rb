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

			it 'does something' do
				byebug
			end
		end

		context 'if the email is a secondary email' do

		end

	end


end