require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "upgrade.rb"



#require_relative "upgrade.rb"
#require_relative "school.rb"
#require_relative "teacher.rb"
#require_relative "review.rb"

# the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

if User.all(type: 3).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.type = 3
	u.save
end

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	erb :index
end

get "/schools" do
	authenticate!
	erb :schools
end

get "/schools/teachers" do
	authenticate!
	erb :teachers
end

get "/schools/new" do
	authenticate!
	if admin
		erb :new
	else
		redirect "/"
	end
end

get "/reviews" do
	authenticate!
	erb :reviews
end