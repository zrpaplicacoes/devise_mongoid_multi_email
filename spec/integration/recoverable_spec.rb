describe 'Recoverable', type: :feature do
  let(:user) { create(:user, :with_secondary_emails, amount_of_secondary_emails: 3) }

  before :each do
    visit new_user_password_path
    expect(user.emails.count).to eq 4 # primary + 3
  end

  context 'with primary email' do
    before :each do
      fill_in 'Email', with: user.email
    end

    context 'when the primary email is confirmed' do
      it 'sends the password reset email' do
        user.primary_email.confirm
        click_reset_password_instructions_button
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content 'You will receive an email with instructions on how to reset your password in a few minutes.'
      end
    end

    context 'when not confirmed' do
      it 'shows an error message of unconfirmed email' do
        click_reset_password_instructions_button
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content 'You will receive an email with instructions on how to reset your password in a few minutes.'
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

end

