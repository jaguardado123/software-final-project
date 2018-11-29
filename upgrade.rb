require "sinatra"
require "stripe"
require_relative "authentication.rb"

set :publishable_key, 'pk_test_NGCWDI3sPpYe7gjHDaGuf7Ba'
set :secret_key, 'sk_test_JCcktuM5C1PIbAs3obxwQiXj'

Stripe.api_key = settings.secret_key

get "/upgrade" do
	authenticate!
	if admin
		redirect "/"
	elsif !pro_user
		erb :upgrade
	end
end

post "/charge" do
	@amount = 500
	@currency = 'usd'

  	customer = Stripe::Customer.create(
    	:email => 'customer@example.com',
    	:source  => params[:stripeToken]
  	)

  	charge = Stripe::Charge.create(
    	:amount      => @amount,
    	:description => 'Sinatra Charge',
    	:currency    => 'usd',
    	:customer    => customer.id
  	)
		
	@u = current_user
	@u.type = 2
	@u.save

	erb :charge
end