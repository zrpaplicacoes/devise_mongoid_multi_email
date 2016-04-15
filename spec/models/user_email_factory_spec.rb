describe 'Email factory' do

	it 'has a valid factory' do
		new_email = build(:email, user: build(:user, :without_email))
		expect(new_email.valid?).to be_truthy
	end

	it 'has a persistable factory' do
		expect(create(:email, user: build(:user, :without_email))).to be_persisted
	end

end