Rails.application.routes.draw do
	root "home#index"

  # mount DeviseMongoidMultiEmail::Engine => "/devise_mongoid_multi_email"

  devise_for :users
end
