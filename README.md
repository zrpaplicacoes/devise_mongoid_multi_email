# DeviseMongoidMultiEmail
A small gem that provides multiple email support for devise with mongoid.

## Usage
Create an `ModelNameEmail` model and add the confirmable fields of devise on it, along with email, as a string field, and primary, as a boolean field.
It requires rails ~> 5.0.0.beta3.

## Installation

```ruby
gem 'devise_mongoid_multi_email'
```

If you want, inherit your confirmation controller from ConfirmationsController.

```ruby
# Example: /user/authentication/confirmations_controller.rb
class User::Authentication::ConfirmationsController < DeviseMongoidMultiEmail::ConfirmationsController
	layout 'user/sessions/main'
end

```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
