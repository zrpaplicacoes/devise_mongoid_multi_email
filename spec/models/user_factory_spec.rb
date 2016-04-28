describe 'User factory' do
	before :each do
		reset_deliveries
	end

	it 'has a valid factory' do
		expect(build(:user).valid?).to be_truthy
		expect(create(:user)).to be_persisted
	end

	it 'has many emails relationship' do
		expect(User.relations.keys.include? "emails").to be_truthy
	end

	it 'has only a single email record if no params are passed to the factory' do
		expect(create(:user).emails.count).to eq 1
	end

	it 'deletes the emails if the user is deleted' do
		user = create(:user, :with_secondary_emails, :amount_of_secondary_emails => 5)
		expect(User.count).to eq 1
		expect(UserEmail.count).to eq 6

		user.delete

		expect(User.count).to eq 0
		expect(UserEmail.count).to eq 0
	end

	it 'deletes the emails if on the user creation the user itself is not valid' do
		user = User.create(email: "test@test.com")
		expect(user.valid?).to be_falsy

		expect(User.count).to eq 0
		expect(UserEmail.count).to eq 0
	end

	it 'updates the primary email of the user if I call update on it' do
		user = User.create(email: "test@test.com", password: "random@12345")
		expect(user.persisted?).to be_truthy

		email = user.emails.first

		expect(email.persisted?).to be_truthy

		old_confirmation_token = user.emails.first.confirmation_token

		user.update(email: "another_email@test.com")
		user.reload
		email.reload

		expect(email.email_with_indiferent_access).to eq "another_email@test.com"
		expect(email.confirmed?).to be_falsy
		expect(email.email).to eq nil
		expect(email.unconfirmed_email).to eq "another_email@test.com"
		expect(email.confirmation_token).to_not eq old_confirmation_token
	end

	it 'sends a confirmation email when I update the primary email' do
		expect(deliveries_size).to eq 0

		user = User.create(email: "test@test.com", password: "random@12345")
		expect(user.persisted?).to be_truthy

		email = user.emails.first

		expect(email.persisted?).to be_truthy

		expect(deliveries_size).to eq 1
		expect(deliveries.first.to.first).to eq 'test@test.com'

		reset_deliveries

		expect(deliveries_size).to eq 0
		user.update(email: "another_email@test.com")

		expect(deliveries_size).to eq 1
		expect(deliveries.first.to.first).to eq 'another_email@test.com'
	end

end
