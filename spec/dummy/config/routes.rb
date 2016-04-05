Rails.application.routes.draw do
  mount DeviseMongoidMultiEmail::Engine => "/devise_mongoid_multi_email"
  devise_for :users
end
