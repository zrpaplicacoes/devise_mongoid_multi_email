FactoryGirl.define do
  factory :user do
  	sequence(:name) { |n| "User number #{n}" }
  	sequence(:email) { |n| "zrp#{n}@zrp.com.br" }
  	password "zrp@12345"
  end
end
