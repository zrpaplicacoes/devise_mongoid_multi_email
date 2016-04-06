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
end
