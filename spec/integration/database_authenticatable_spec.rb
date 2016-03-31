describe 'database authentication' do
  it 'returns true' do
  	user = User.create
  	expect(user.confirmed?).to be_truthy
  end
end