describe 'User factory' do
	it 'has a valid factory' do
		expect(build(:user).valid?).to be_truthy
		expect(create(:user)).to be_persisted
	end
end
