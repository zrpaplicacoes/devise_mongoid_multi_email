desc "Install configs to the specified model"
namespace 'devise_mongoid_multi_email' do
	task :install, [:model] do |t, args|
		puts "Installing for model #{args.model}"
	end
end
