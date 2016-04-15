describe 'Devise integration' do
  context 'when I create an user' do
  	let(:user) { create(:user) }
  	let(:email_record) { user.primary_email }

    it 'expects the user to have a single email record' do
      expect(user.emails.count).to eq 1
    end

  	it 'has an unconfirmed primary email' do
  		expect(email_record.email).to be nil
  		expect(email_record.unconfirmed_email).to_not be nil
  		expect(email_record.confirmed?).to be_falsy
  	end

  	it 'confirms the email if I call #confirm on the user model' do
  		expect(user.confirm).to be_truthy
  		expect(user.confirmed?).to be_truthy
  	end

  	it 'confirms the email if I call #confirm on the email model' do
  		expect(email_record.confirm).to be_truthy
  		expect(user.confirmed?).to be_truthy
  		expect(email_record.confirmed?).to be_truthy
  	end

  	it 'returns true for #confirmed if user has a confirmed email' do
  		user.confirm
  		expect(user.confirmed?).to be_truthy
  	end

    it 'returns false for #confirmed? if user has no confirmed emails' do
  		expect(user.confirmed?).to be_falsy
  	end

  	it 'confirms all users emails if I call #confirm_all on the user' do
  		user.emails << create_list(:email, 3, :secondary, user: user)
  		expect(user.emails.size).to eq 4 # creation email + 3

  		user.emails.each do |record|
  			expect(record.confirmed?).to be_falsy
  		end

  		user.confirm_all

  		user.emails.each do |record|
  			expect(record.confirmed?).to be_truthy
  		end
  	end

  end


end