describe 'database authentication', type: :feature do
	let(:user) { create(:user) }

	before :each do
		visit new_user_session_path
	end

	context 'if the email is a primary email' do
		before :each do
			fill_login_form_with email: user.email, password: user.password
		end

		context 'if the email is confirmed' do
			it 'allows the user to sign in' do
				user.confirm
				click_button 'Log in'
				expect(current_path).to eq root_path
				byebug
				expect(page).to have_css '.cpy-signed-in'
			end
		end

		context 'if the email is unconfirmed but a secondary email is confirmed' do
		end

		context 'if the email is unconfirmed and no secondary email is confirmed' do
			it 'displays an error message of unconfirmed email' do
				click_button 'Log in'
				expect(page).to have_content ""
			end
		end

	end


	context 'if the email is a secondary email' do
		context 'if the email is unconfirmed but the primary email is confirmed' do

		end

		context 'if the email is unconfirmed and the primary email is unconfirmed' do
		end

	end



end