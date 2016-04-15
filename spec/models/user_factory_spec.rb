describe 'User factory' do

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

end
