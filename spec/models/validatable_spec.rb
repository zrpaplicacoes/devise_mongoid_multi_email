describe 'Validatable' do
	let(:error_messages) { OpenStruct.new({
			blank: "can't be blank",
			invalid_format: "is invalid",
			already_taken: "is already taken"
		})
	}

	context 'Email class' do

		it 'includes the validation module inside the email class' do
			expect(UserEmail.included_modules.include?(::DeviseMongoidMultiEmail::EmailValidators)).to be_truthy
		end

		context 'if the email format is invalid' do
			let(:email) { UserEmail.new(unconfirmed_email: "invalid_email", primary: false) }

			it 'returns false to #valid?' do
				expect(email.valid?).to be_falsy
			end

			it 'adds an error message of invalid format' do
				email.valid?
				expect(email.errors['email']).to match_array [error_messages.invalid_format]
			end

		end

		context 'if the email is blank' do
			let(:email) { UserEmail.new(unconfirmed_email: "", primary: false) }

			it 'returns false to #valid?' do
				expect(email.valid?).to be_falsy
			end

			it 'adds an error message of cant be blank' do
				email.valid?
				expect(email.errors['email']).to match_array [error_messages.blank]
			end

		end

		context 'if the email already exists and is confirmed' do
			let(:email) { UserEmail.new(unconfirmed_email: "test@test.com", primary: false) }
			let(:identical_email) { UserEmail.new(unconfirmed_email: "test@test.com", primary: false) }
			let(:other_users) { create_list(:user, 2) }

			before :each do
				@user = create(:user)
				@user.emails << email

				email.reload

				expect(email.persisted?).to be_truthy
				expect(email.user).to eq @user
				# confirms all user emails, including the appended one

				@user.confirm_all
				@user.emails.each do |record|
					expect(record.confirmed?).to be_truthy
				end

			end

			it 'does not allow any user to create it' do
				another_user = other_users.first

				another_user.emails << identical_email

				expect {
					another_user.save!
				}.to raise_error Mongoid::Errors::Validations

			end

			it 'returns false to #valid?' do
				new_email = UserEmail.new(unconfirmed_email: "test@test.com", primary: false, user: other_users.first)
				expect(new_email.valid?).to be_falsy
			end

			it 'adds an error message of already taken' do
				new_email = UserEmail.new(unconfirmed_email: "test@test.com", primary: false, user: other_users.first)
				new_email.valid?
				expect(new_email.errors['email']).to match_array [error_messages.already_taken]
			end

		end

		context 'if the email already exists and is unconfirmed' do
			let(:email) { UserEmail.new(unconfirmed_email: "test@test.com", primary: false) }
			let(:identical_email) { UserEmail.new(unconfirmed_email: "test@test.com", primary: false) }
			let(:other_users) { create_list(:user, 2) }

			before :each do
				@user = create(:user)
				expect(@user.persisted?).to be_truthy

				@user.emails << email
				@user.save!

				@user.reload
				email.reload

				expect(@user.emails.count).to eq 2
				expect(email.persisted?).to be_truthy
				expect(email.user).to eq @user
				expect(email.confirmed?).to be_falsy
			end

			it 'allows other users to create this email' do
				another_user = other_users.first

				another_user.emails << identical_email
				expect { another_user.save! }.to_not raise_error

				another_user.save!

				another_user.reload
				identical_email.reload

				expect(another_user.emails.where(unconfirmed_email: email.email_with_indiferent_access).first).to eq identical_email
				expect(identical_email.persisted?).to be_truthy
				expect(identical_email.confirmed?).to be_falsy

				identical_emails = UserEmail.where(unconfirmed_email: identical_email.email_with_indiferent_access).to_a

				expect(identical_emails.size).to eq 2
				expect(identical_emails.map(&:user)).to match_array [ @user, another_user ]
			end

			it 'does not allow the same user to add this email to his emails' do
				expect(@user.emails.count).to eq 2
				expect { @user.emails << identical_email }.to raise_error Mongoid::Errors::Validations
				@user.reload
				expect(@user.emails.count).to eq 2
			end

			it 'is removed from all users when an user confirms it' do
				another_user = other_users.first
				another_user_2 = other_users.last
				create_list(:email, 2, :secondary, user: another_user_2)

				another_user.emails << identical_email
				another_user_2.emails << UserEmail.new(unconfirmed_email: "test@test.com", primary: false)

				expect(@user.emails.count).to eq 2
				expect(another_user.emails.count).to eq 2
				expect(another_user_2.emails.count).to eq 4

				expect { another_user.save! }.to_not raise_error
				expect { another_user_2.save! }.to_not raise_error

				identical_email.confirm

				@user.reload
				another_user.reload
				another_user_2.reload
				identical_email.reload

				expect(@user.emails.map(&:confirmed?).any?).to be_falsy
				expect(another_user.emails.map(&:confirmed?).any?).to be_truthy
				expect(another_user_2.emails.map(&:confirmed?).any?).to be_falsy

				expect(@user.emails.count).to eq 1
				expect(another_user.emails.count).to eq 2
				expect(another_user_2.emails.count).to eq 3

			end

			it 'is not confirmed if persisted' do
				another_user = other_users.first
				another_user.emails << identical_email
				expect { another_user.save! }.to_not raise_error

				identical_email.reload

				expect(identical_email.confirmed?).to be_falsy
			end

		end

		context 'if the email does not exist' do
			let(:email) { UserEmail.new(unconfirmed_email: "test@test.com") }

			it 'returns an error if the email does not belong to an user' do
				expect { email.save! }.to raise_error Mongoid::Errors::Validations
			end

			it 'is persisted if the email belongs to an user' do
				user = create(:user)
				user.emails << email
				email.reload
				expect(email.user).to eq user
				expect(email.persisted?).to be_truthy
			end

			it 'is not persisted if the email does not have an user' do
				email.save

				email.reload

				expect(email.persisted?).to be_falsy
			end

			it 'is not confirmed if persisted' do
				user = create(:user)
				user.emails << email
				email.reload
				expect(email.user).to eq user
				expect(email.confirmed?).to be_falsy
			end

		end

	end

	context 'Resource class' do
		let(:user) { create(:user) }
		let(:new_invalid_primary_email) { UserEmail.new(primary: true, unconfirmed_email: "test@test.com", user: user) }

		it 'does not allow multiple primary emails' do
			expect { create(:email, primary: true, user: user) }.to raise_error Mongoid::Errors::Validations

			expect(new_invalid_primary_email.valid?).to be_falsy
			expect(new_invalid_primary_email.errors['primary']).to match_array [error_messages.already_taken]

		end

		it 'does not allow me to save an user if the emails relation is invalid' do
		  user.emails << new_invalid_primary_email

			expect { user.save! }.to raise_error Mongoid::Errors::Validations

		end

	end

end