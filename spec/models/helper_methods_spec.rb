describe 'Devise::Login helper methods' do
	let(:user) { User.new }

	context 'public instance helper methods' do

		it 'includes a method to see if the primary email changed' do
			expect(user.respond_to? :email_changed?).to be_truthy
			expect(user.email_changed?).to be_falsy
			user.emails << Email.new
			expect(user.email_changed?).to be_truthy
		end

		context "#email" do
			it 'responds to the method' do
				expect(user.respond_to? :email).to be_truthy
			end

			it 'returns the user primary email' do
				user.emails << build(:email, :confirmed, email: "test@test.com")
				expect(user.email).to eq "test@test.com"
			end

			it 'returns a empty string if the user does not have a primary email' do
				user.emails << build(:email, :secondary, email: "test@test.com")
				expect(user.email).to eq ""
			end
		end

		context "#first_email_record" do
			it 'responds to the method' do
				expect(user.respond_to? :first_email_record).to be_truthy
			end

			it 'returns the primary email record if it is available' do
				new_primary_email = build(:email)
				user.emails << new_primary_email
				expect(user.first_email_record).to eq new_primary_email
				expect(user.first_email_record).to eq user.primary_email
			end

			it 'returns the user secondary email if the user does not have a primary email' do
				new_secondary_email = build(:email, :secondary)
				user.emails << new_secondary_email
				expect(user.first_email_record).to eq new_secondary_email
			end

		end

		context "#active_for_authentication" do
			it 'responds to the method' do
				expect(user.respond_to? :active_for_authentication?).to be_truthy
			end

			it 'returns false if the user has not confirmed any of his email' do
				expect(user.confirmed?).to be_falsy
				expect(user.active_for_authentication?).to be_falsy
			end

			it 'returns true if the user has confirmed his primary email' do
				user = create(:user)
				primary_email = user.emails.where(primary: true).first
				primary_email.confirm
				expect(primary_email.confirmed?).to be_truthy
				user.reload
				expect(user.active_for_authentication?).to be_truthy
			end

			it 'returns true if the user has confirmed his secondary emails but not his primary email' do
				user = create(:user)
				primary_email = user.emails.where(primary: true).first
				secondary_emails = create_list(:email, 4, :secondary, user: user)
				secondary_emails.each { |email| email.confirm }
				expect(primary_email.confirmed?).to be_falsy
				user.reload
				expect(user.active_for_authentication?).to be_falsy
			end
		end

	end

	context 'public class helper methods' do
		# Class modifications reset
		before :each do
			User.reset_devise_email_association
		end

		after :each do
			User.reset_devise_email_association
		end

		it 'includes a method to retrieve the class association' do
			expect(User.respond_to? :email_class).to be_truthy
		end

		it 'changes the class association symbol if I call the email association setter' do
			expect{ User.devise_email_association(:user_emails) }.to_not raise_error
			expect(User.get_devise_email_association).to eq :user_emails
		end

		it 'returns the default association symbol if none is passed' do
			expect(User.get_devise_email_association).to eq :emails
		end

		it 'returns the email class if I call #email_class method on class' do
			expect(User.email_class).to eq Email
		end

		context "#find_first_by_auth_conditions" do
			it 'returns the user if I search for his primary email' do
				users = create_list(:user, 4)
				user = users.first
				users.each { |user| expect(user).to be_persisted }
				expect(user.first_email_record).to be_persisted
				users.each { |user| user.confirm }
				expect(user.first_email_record.confirmed?).to be_truthy
				email_to_find = user.email
				expect(User.find_first_by_auth_conditions({ email: email_to_find })).to eq user
			end

			it 'returns the user if I search for his secondary email' do
				users = create_list(:user, 4)
				user = users.first
				secondary_email = create(:email, :secondary, user: user, unconfirmed_email: "secondary_email@test.com")
				secondary_email.confirm
				expect(User.find_first_by_auth_conditions({ email: secondary_email.email } )).to eq user
			end

			it 'returns nil if the email does not exist' do
				user = create(:user)
				expect(User.find_first_by_auth_conditions( { email: "unavailable_email@zrp.com.br" })).to eq nil
			end

			it 'returns the user, even if the email is not confirmed' do
				user = create(:user)
				expect(user.confirmed?).to be_falsy
				expect(User.find_first_by_auth_conditions( { email: user.email } )).to eq user
			end

		end

	end
end