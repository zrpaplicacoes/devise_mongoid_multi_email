describe 'Recoverable', type: :feature do
  let(:user) { create(:user, :with_secondary_emails, amount_of_secondary_emails: 3) }

  before :each do
    visit new_user_password_path
    expect(user.emails.count).to eq 4 # primary + 3
  end

  after :each do
    ActionMailer::Base.deliveries = []
  end

  context 'with primary email' do
    let(:primary_email) { user.primary_email }
    let(:mail_to) { primary_email.email_with_indiferent_access }

    before :each do
      fill_in 'Email', with: mail_to
    end

    context 'when the primary email is confirmed' do
      before :each do
        primary_email.confirm
      end

      it 'redirects the user to the login page and displays a success message' do
        click_reset_password_instructions_button
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content 'You will receive an email with instructions on how to reset your password in a few minutes.'
      end

      it 'sends an email to the passed email' do
        ActionMailer::Base.deliveries = []
        click_reset_password_instructions_button
        email = ActionMailer::Base.deliveries[0]
        expect(email.subject).to eq 'Reset password instructions'
        expect(email.from).to match_array [Devise.mailer_sender]
        expect(email.to).to match_array [mail_to]
      end
    end

    context 'when not confirmed' do
      before :each do
        expect(primary_email.confirmed?).to be_falsy
      end

      it 'shows an error message of unconfirmed email' do
        click_reset_password_instructions_button
        expect(current_path).to eq '/users/password'
        expect(page).to have_content 'Email not found or unconfirmed'
      end

      it 'does not send any emails' do
        ActionMailer::Base.deliveries = []
        click_reset_password_instructions_button
        expect(ActionMailer::Base.deliveries.size).to eq 0
      end
    end
  end

  context 'with secondary email' do
    let(:secondary_email) { user.secondary_emails[0] }
    let(:mail_to) { secondary_email.email_with_indiferent_access }
    before :each do
      fill_in 'Email', with: mail_to
    end

    context 'when the secondary email is confirmed and the primary email is confirmed' do
      before :each do
        user.primary_email.confirm
        secondary_email.confirm
        expect(user.primary_email.confirmed?).to be_truthy
        expect(secondary_email.confirmed?).to be_truthy
      end

      it 'redirects the user to the login page and displays a success message' do
        click_reset_password_instructions_button
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content 'You will receive an email with instructions on how to reset your password in a few minutes.'
      end

      it 'sends an email to the passed email' do
        ActionMailer::Base.deliveries = []
        click_reset_password_instructions_button
        email = ActionMailer::Base.deliveries[0]
        expect(email.subject).to eq 'Reset password instructions'
        expect(email.from).to match_array [Devise.mailer_sender]
        expect(email.to).to match_array [mail_to]
      end
    end

    context 'when the secondary email is confirmed and the primary email is not confirmed' do
      before :each do
        secondary_email.confirm
        expect(user.primary_email.confirmed?).to be_falsy
        expect(secondary_email.confirmed?).to be_truthy
      end

      it 'shows an error message of unconfirmed email' do
        click_reset_password_instructions_button
        expect(current_path).to eq '/users/password'
        expect(page).to have_content 'Email not found or unconfirmed'
      end

      it 'does not send any emails' do
        ActionMailer::Base.deliveries = []
        click_reset_password_instructions_button
        expect(ActionMailer::Base.deliveries.size).to eq 0
      end

    end

    context 'when not confirmed' do
      before :each do
        expect(secondary_email.confirmed?).to be_falsy
      end

      it 'shows an error message of unconfirmed email' do
        click_reset_password_instructions_button
        expect(current_path).to eq '/users/password'
        expect(page).to have_content 'Email not found or unconfirmed'
      end

      it 'does not send any emails' do
        ActionMailer::Base.deliveries = []
        click_reset_password_instructions_button
        expect(ActionMailer::Base.deliveries.size).to eq 0
      end
    end
  end


  context 'with non-existing email' do
    before :each do
      fill_in 'Email', with: "#{SecureRandom.base64}@example.com"
      click_reset_password_instructions_button
    end

    it 'shows email does not exist' do
      expect(current_path).to eq '/users/password'
      expect(page).to have_content 'Email not found or unconfirmed'
    end
  end

  context 'with blank email' do
    before :each do
      fill_in 'Email', with: ""
      click_reset_password_instructions_button
    end

    it 'shows an error message of email could not be blank' do
      expect(current_path).to eq '/users/password'
      expect(page).to have_content "Email can't be blank"
    end
  end

end

