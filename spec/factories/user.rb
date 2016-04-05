FactoryGirl.define do
  factory :user do
  	sequence(:name) { |n| "User number #{n}" }
  	sequence(:email) { |n| "zrp#{n}@zrp.com.br" }
  	password "zrp@12345"

		trait :with_secondary_emails do
			transient do
				amount_of_secondary_emails 1
			end

			after(:build) do |user, evaluator|
				user.emails << create_list(:email, evaluator.amount_of_secondary_emails, :secondary, user: user)
			end
		end

  end
end
