require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "upgrade.rb"
require_relative "school.rb"
require_relative "teacher.rb"
require_relative "review.rb"

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
	@schools = School.all
	erb :schools
end

get("/schools/teachers/:id") do
	authenticate!
	@teachers = Teacher.all(Teacher.school_id => params[:id].to_i)
	erb :teachers
end


get("/schools/teachers/:id/:name") do
	authenticate!
	erb :reviews
end

get "/schools/new" do
	authenticate!
	if admin
		@schools = School.all
		erb :new
	else
		redirect "/"
	end
end

post "/schools/create_school" do
	authenticate!
	if params[:school_name] && 
		sch = School.new
		sch.name = params[:school_name]
		sch.save
		flash[:success] = "Succesfully Added #{sch.name}"
	end
	
	redirect"/schools/new"
end

post "/schools/create_teacher" do
	if params[:teacher_name] && params[:select_school]
		tch = Teacher.new
		tch.name = params[:teacher_name]
		t = School.first(:name => params[:select_school])
		tch.school_id = t.id
		tch.save
		flash[:success] = "Succesfully Added #{tch.name}"
	end

	redirect"/schools/new"
end


get "/reviews" do
	authenticate!
	erb :reviews
end