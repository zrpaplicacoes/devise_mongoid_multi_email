FactoryGirl.define do
	factory :email, class: UserEmail do
		sequence(:unconfirmed_email) { |n| "zrp_#{n}@zrp.com.br" }
		primary true

		trait :confirmed do
			email { unconfirmed_email }
			unconfirmed_email nil
			confirmed_at { Time.zone.now }
		end

		trait :secondary do
			primary false
		end

	end
end
