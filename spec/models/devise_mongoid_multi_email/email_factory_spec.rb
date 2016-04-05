describe 'Email factory' do
	it 'has a valid factory' do
		expect(build(:email).valid?).to be_truthy
		expect(create(:email)).to be_persisted
	end
end